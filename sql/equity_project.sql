CREATE TABLE prices (
    ticker VARCHAR(6),
    date DATE,
    open NUMERIC(7, 2),
    high NUMERIC(7, 2),
    low NUMERIC(7, 2),
    close NUMERIC(7, 2),
    volume INTEGER,
    PRIMARY KEY (ticker, date)
);

