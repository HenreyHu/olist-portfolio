import duckdb
c = duckdb.connect('data/olist.duckdb', read_only=True)
sql = open('sql/03_analysis.sql', encoding='utf-8').read()
for i, q in enumerate([s for s in sql.split(';') if s.strip()], 1):
    r = c.sql(q)
    r.write_csv(f'results/q{i}.csv')
    print(f'--- q{i} ---')
    print(r.limit(15))
