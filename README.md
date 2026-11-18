# COBOL Transaction Batch Checker

A small COBOL project that reads a daily transaction file, checks each record, and produces a reconciliation report. It uses fixed-width input records and line-sequential file processing.

## What it checks

- Transaction ID and account ID are present
- Transaction type is `C` (credit) or `D` (debit)
- Amount is eight numeric digits and greater than zero
- A transaction ID has not already been accepted in the same batch

Rejected records are listed in the report but excluded from the totals. The program keeps up to 1,000 accepted transaction IDs in memory to catch duplicates; later records are rejected when that limit is reached.

## Run it

Install GnuCOBOL and run from the project directory:

```bash
chmod +x run.sh tests/test.sh
./run.sh
```

The script compiles `src/batch_checker.cbl` and writes `output/batch_report.txt`.

Run the sample checks with:

```bash
./tests/test.sh
```

On Debian or Ubuntu, GnuCOBOL is available through `sudo apt install gnucobol`.

## Input format

The file `data/transactions.txt` contains one 23-character record per line. The fields are directly adjacent; there are no separators.

| Position | Field | Format |
| --- | --- | --- |
| 1–6 | Transaction ID | 6 characters |
| 7–14 | Account ID | 8 characters |
| 15 | Transaction type | `C` or `D` |
| 16–23 | Amount | 8 digits, in cents |

Example:

```text
TX0001AC000001C00001250
```

This represents a credit of 1,250 cents to account `AC000001`. The sample file includes valid transactions, invalid records, and a duplicate ID.

## Expected sample totals

```text
Processed: 9
Accepted: 5
Rejected: 4
Credits: 1549
Debits: 2399
Net movement: DEBIT 850
```

This is a file-processing exercise, not a complete payment system. It does not move money, maintain account balances, or connect to a bank.
