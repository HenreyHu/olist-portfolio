"""Run one .sql file against data/olist.duckdb.  Usage: python scripts/run_sql.py sql/02_cleaning.sql"""
import sys
import duckdb

c = duckdb.connect('data/olist.duckdb')
sql = open(sys.argv[1], encoding='utf-8-sig').read()
for stmt in c.extract_statements(sql):  # DuckDB's own parser, so a ';' inside a string or comment is safe
    r = c.execute(stmt)
    if r.description:
        print(r.fetchall())
