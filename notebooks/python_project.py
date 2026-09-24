import yfinance as yf
import pandas as pd
import sqlalchemy
from dotenv import load_dotenv
import os

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