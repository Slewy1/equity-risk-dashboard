import yfinance as yf
import pandas as pd
import sqlalchemy



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
