import yfinance as yf
import pandas as pd
import sqlalchemy
from dotenv import load_dotenv
import os
import numpy as np

load_dotenv()

data = yf.download(
    ['NVDA', 'MU', 'AAPL', 'XOM', 'CVX', 'SHEL', 'GSK', 'JNJ', 'UNH', 'JPM', 'V', 'BLK', 'GLD', 'SLV', 'CPER'],
    start='2020-01-01',
    end='2026-01-01'
)

stocks = ['NVDA', 'MU', 'AAPL', 'XOM', 'CVX', 'SHEL', 'GSK', 'JNJ', 'UNH', 'JPM', 'V', 'BLK', 'GLD', 'SLV', 'CPER']

# for i in stocks:
#     if yf.Ticker(i).info.get('currency') == 'USD':
#         pass
#     else:
#         print(f"{i} not in USD")



transposed = data.stack(level='Ticker')
transposed = transposed.reset_index()
transposed.columns.name = None
transposed.columns = transposed.columns.str.lower()

print(transposed.head())
print(transposed.columns)



db_host = os.getenv('DB_HOST')
db_port = os.getenv('DB_PORT')
db_name = os.getenv('DB_NAME')
db_user = os.getenv('DB_USER')
db_password = os.getenv('DB_PASSWORD')

connection_string = f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
engine = sqlalchemy.create_engine(connection_string)

with engine.connect() as conn:
    print("Connected successfully")


# transposed.to_sql('prices', engine, if_exists='append', index=False)


with engine.connect() as conn:
    result = conn.execute(sqlalchemy.text("SELECT COUNT(*) FROM prices"))
    print(result.fetchone())

risk_metric = pd.read_sql('risk_metrics_view', engine)
correlation = pd.read_sql('correlation_view', engine)

summary = risk_metric.groupby("ticker").agg(
    max_drawdown=('drawdown','min'),
    final_wealth=('cumulative_wealth','last'),
    volatility=('volatility', 'mean')
)

# percentage return
summary['total_return'] = (summary["final_wealth"] - 1000) / 1000 * 100

print(summary)

correlation_pivot = correlation.pivot_table(
    index="asset_a",
    columns="asset_b",
    values="correlation"
)

# Include all tickers in both asset a and b
all_tickers = sorted(set(correlation['asset_a']).union(correlation['asset_b']))
correlation_pivot = correlation_pivot.reindex(index=all_tickers, columns=all_tickers)
# Fill NaN with correct values
correlation_pivot = correlation_pivot.fillna(correlation_pivot.T)
np.fill_diagonal(correlation_pivot.values, 1.0)

print(correlation_pivot)