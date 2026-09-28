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
),

cumvol AS (SELECT
    ticker,
    date,
    close,
    daily_return,
    STDDEV_SAMP(daily_return) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS volatility,
    1000 * EXP(SUM(LN(1 + COALESCE(daily_return, 0))) OVER (PARTITION BY ticker ORDER BY date)) AS cumulative_wealth
FROM returns
),

peak AS (SELECT
    ticker,
    date,
    close,
    daily_return,
    volatility,
    cumulative_wealth,
    MAX(cumulative_wealth) OVER (PARTITION BY ticker ORDER BY date) AS running_peak
FROM cumvol
)


SELECT
    ticker,
    date,
    close,
    round(daily_return, 2) AS daily_return,
    round(volatility, 2) AS volatility,
    round(cumulative_wealth, 2) AS cumulative_wealth,
    round(running_peak, 2) AS running_peak,
    round((cumulative_wealth - running_peak) / running_peak, 2) AS drawdown
FROM peak




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
),


correlation_setup AS (SELECT
    a.date,
    a.ticker AS asset_a,
    b.ticker AS asset_b,
    a.daily_return AS asset_a_return,
    b.daily_return AS asset_b_return
FROM returns a
CROSS JOIN returns b
WHERE a.ticker > b.ticker
 AND a.date = b.date
)

SELECT
    asset_a,
    asset_b,
    ROUND(CORR(asset_a_return, asset_b_return)::numeric, 2) AS correlation
FROM correlation_setup
GROUP BY asset_a, asset_b