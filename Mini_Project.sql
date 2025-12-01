#Question 1
SELECT
    Reporting_Airline AS Airline,
    MAX(DepDelay)    AS MaxDepartureDelay
FROM al_perf
GROUP BY Reporting_Airline
ORDER BY MaxDepartureDelay ASC;
#Rows Returned: 17

#Question 2
SELECT
    Reporting_Airline AS Airline,
    MIN(DepDelay)     AS MaxEarlyDeparture
FROM al_perf
GROUP BY Reporting_Airline
ORDER BY MaxEarlyDeparture ASC;
#Rows Returned: 17

#Question 3
SELECT
    DayOfWeek,
    COUNT(*) AS NumFlights,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS BusyRank
FROM al_perf
GROUP BY DayOfWeek
ORDER BY BusyRank;
#Rows Returned: 8

#Question 4
SELECT
	OriginAirportID,
    Origin AS Airport,
    AVG(GREATEST(DepDelay, 0)) AS AvgDepartureDelay
FROM al_perf
GROUP BY Origin
ORDER BY AvgDepartureDelay DESC
LIMIT 1;
#Rows Returned: 1

#Question 5
WITH airline_airport_delays AS (
    SELECT
        Reporting_Airline AS Airline,
        Origin            AS Airport,
        AVG(GREATEST(DepDelay, 0)) AS AvgDepartureDelay
    FROM al_perf
    GROUP BY Reporting_Airline, Origin
)
SELECT
    Airline,
    Airport,
    AvgDepartureDelay
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Airline
            ORDER BY AvgDepartureDelay DESC
        ) AS rn
    FROM airline_airport_delays
) t
WHERE rn = 1
ORDER BY Airline;
#Rows Returned: 17

#Question 6A
SELECT
    COUNT(*) AS NumCanceledFlights
FROM al_perf
WHERE Cancelled = 1;
#Rows Returned: 1

#Question 6B
WITH cancel_counts AS (
    SELECT
        Origin          AS Airport,
        CancellationCode,
        COUNT(*)        AS NumCancellations
    FROM al_perf
    WHERE
        Cancelled = 1
        AND CancellationCode IS NOT NULL
        AND CancellationCode <> ''
    GROUP BY Origin, CancellationCode
)
SELECT
    Airport,
    CancellationCode,
    NumCancellations
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Airport
            ORDER BY NumCancellations DESC
        ) AS rn
    FROM cancel_counts
) t
WHERE rn = 1
ORDER BY Airport;
#Rows Returned: 258

#Question 7
WITH daily_counts AS (
    SELECT
        FlightDate,
        COUNT(*) AS NumFlights
    FROM al_perf
    GROUP BY FlightDate
)
SELECT
    FlightDate,
    NumFlights,
    AVG(NumFlights) OVER (
        ORDER BY FlightDate
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ) AS AvgPrev3Days
FROM daily_counts
ORDER BY FlightDate;
#Rows Returned: 32
