       >>SOURCE FORMAT FREE
identification division.
program-id. batch-checker.

environment division.
input-output section.
file-control.
    select transaction-file assign to "data/transactions.txt"
        organization is line sequential
        file status is transaction-status.
    select report-file assign to "output/batch_report.txt"
        organization is line sequential
        file status is report-status.

data division.
file section.
fd transaction-file.
01 transaction-record.
    05 transaction-id       pic x(6).
    05 account-id           pic x(8).
    05 movement-type        pic x.
    05 amount-text          pic x(8).

fd report-file.
01 report-line              pic x(120).

working-storage section.
01 transaction-status       pic xx.
01 report-status            pic xx.
01 eof-reached              pic 9 value 0.
01 rejection-reason         pic x(28).
01 result-text              pic x(44).
01 amount-cents             pic 9(8).
01 processed-count          pic 9(5) value 0.
01 accepted-count           pic 9(5) value 0.
01 rejected-count           pic 9(5) value 0.
01 credit-total             pic 9(12) value 0.
01 debit-total              pic 9(12) value 0.
01 net-amount               pic 9(12) value 0.
01 net-direction            pic x(6).
01 count-display            pic z(4)9.
01 amount-display           pic z(11)9.
01 stored-count             pic 9(4) comp value 0.
01 stored-index             pic 9(4) comp value 0.
01 transaction-ids.
    05 stored-id            pic x(6) occurs 1000 times.

procedure division.
main.
    open input transaction-file
    if transaction-status not = "00"
        display "Cannot open data/transactions.txt"
        move 1 to return-code
        goback
    end-if

    open output report-file
    if report-status not = "00"
        display "Cannot write output/batch_report.txt"
        close transaction-file
        move 1 to return-code
        goback
    end-if

    move "TRANSACTION BATCH REPORT" to report-line
    write report-line
    move "ID     | ACCOUNT  | TYPE | CENTS    | RESULT" to report-line
    write report-line

    perform until eof-reached = 1
        read transaction-file
            at end move 1 to eof-reached
            not at end perform process-transaction
        end-read
    end-perform

    perform write-summary
    close transaction-file report-file
    display "Report written to output/batch_report.txt"
    goback.

process-transaction.
    add 1 to processed-count
    move spaces to rejection-reason

    evaluate true
        when transaction-id = spaces
            move "MISSING TRANSACTION ID" to rejection-reason
        when account-id = spaces
            move "MISSING ACCOUNT ID" to rejection-reason
        when movement-type not = "C" and movement-type not = "D"
            move "INVALID TYPE" to rejection-reason
        when amount-text is not numeric
            move "INVALID AMOUNT" to rejection-reason
        when amount-text = "00000000"
            move "ZERO AMOUNT" to rejection-reason
        when other
            perform check-duplicate
    end-evaluate

    if rejection-reason = spaces and stored-count >= 1000
        move "BATCH LIMIT REACHED" to rejection-reason
    end-if

    if rejection-reason = spaces
        perform accept-transaction
    else
        add 1 to rejected-count
        move spaces to result-text
        string "REJECTED: " function trim(rejection-reason)
            delimited by size into result-text
        end-string
    end-if

    perform write-detail.

check-duplicate.
    perform varying stored-index from 1 by 1
        until stored-index > stored-count
        if transaction-id = stored-id(stored-index)
            move "DUPLICATE ID" to rejection-reason
            exit perform
        end-if
    end-perform.

accept-transaction.
    move amount-text to amount-cents
    if movement-type = "C"
        add amount-cents to credit-total
    else
        add amount-cents to debit-total
    end-if
    add 1 to accepted-count
    add 1 to stored-count
    move transaction-id to stored-id(stored-count)
    move "ACCEPTED" to result-text.

write-detail.
    move spaces to report-line
    string transaction-id " | " account-id " | "
        movement-type " | " amount-text " | "
        function trim(result-text)
        delimited by size into report-line
    end-string
    write report-line.

write-summary.
    move spaces to report-line
    write report-line
    move "SUMMARY (all amounts in cents)" to report-line
    write report-line

    move processed-count to count-display
    move spaces to report-line
    string "Processed: " function trim(count-display)
        delimited by size into report-line
    end-string
    write report-line

    move accepted-count to count-display
    move spaces to report-line
    string "Accepted: " function trim(count-display)
        delimited by size into report-line
    end-string
    write report-line

    move rejected-count to count-display
    move spaces to report-line
    string "Rejected: " function trim(count-display)
        delimited by size into report-line
    end-string
    write report-line

    move credit-total to amount-display
    move spaces to report-line
    string "Credits: " function trim(amount-display)
        delimited by size into report-line
    end-string
    write report-line

    move debit-total to amount-display
    move spaces to report-line
    string "Debits: " function trim(amount-display)
        delimited by size into report-line
    end-string
    write report-line

    if credit-total >= debit-total
        compute net-amount = credit-total - debit-total
        move "CREDIT" to net-direction
    else
        compute net-amount = debit-total - credit-total
        move "DEBIT" to net-direction
    end-if

    move net-amount to amount-display
    move spaces to report-line
    string "Net movement: " function trim(net-direction)
        " " function trim(amount-display)
        delimited by size into report-line
    end-string
    write report-line.
