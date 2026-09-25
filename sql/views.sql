WITH previous AS (SELECT
    ticker,
    date,
    CLOSE,
    LAG(close) OVER (PARTITION BY ticker ORDER BY date) AS previous_close
FROM prices
),

returns AS (SELECT
    ticker,
    date,
    close,
    (close - previous_close) / previous_close AS daily_return
FROM previous
)

SELECT
    ticker,
    date,
    close,
    round(daily_return, 2) AS daily_return,
    ROUND(STDDEV_SAMP(daily_return) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS volatility,
    1000 * EXP(SUM(LN(1 + COALESCE(daily_return, 0))) OVER (PARTITION BY ticker ORDER BY date)) AS cumulative_wealth
FROM returns
