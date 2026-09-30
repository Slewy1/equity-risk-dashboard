CREATE OR REPLACE VIEW risk_metrics_view AS (
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
    STDDEV_SAMP(daily_return) OVER (PARTITION BY ticker ORDER BY date ROWS BETWEEN 19 PRECEDING AND CURRENT ROW) AS volatility,
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
    daily_return,
    volatility,
    cumulative_wealth,
    running_peak,
    (cumulative_wealth - running_peak) / running_peak AS drawdown
FROM peak
);


CREATE VIEW correlation_view AS (
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
    CORR(asset_a_return, asset_b_return) AS correlation
FROM correlation_setup
GROUP BY asset_a, asset_b
);
