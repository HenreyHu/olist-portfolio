import sys, duckdb
c = duckdb.connect('data/olist.duckdb')
for s in open(sys.argv[1], encoding='utf-8-sig').read().split(';'):
    if s.strip():
        r = c.execute(s)
        if r.description:
            print(r.fetchall())
