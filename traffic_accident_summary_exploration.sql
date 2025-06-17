----- Tổng quan
-- Tổng số vụ tai nạn giao thông ở các năm?
SELECT
    YEAR(DATE) AS YEAR,
    COUNT([ACCIDENT ID]) AS 'TOTAL ACCIDENTS'
FROM traffic_accidents
GROUP BY YEAR(DATE)
ORDER BY YEAR(DATE);

-- Tổng số thương vong?
SELECT 
    YEAR(DATE) AS YEAR,
    SUM(CASUALTIES) AS CASUALTIES
FROM traffic_accidents
GROUP BY YEAR(DATE) 
ORDER BY YEAR(DATE);

-- Số vụ tai nạn ở từng tháng giữa các năm và tỷ lệ tăng trưởng?
WITH CTE0 AS (
    SELECT 
        MONTH(DATE) AS MONTH,
        CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS FLOAT) AS '2023',
        CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS FLOAT) AS '2024'
    FROM traffic_accidents
    GROUP BY MONTH(DATE)
)
SELECT 
    MONTH,
    [2023],[2024],
    ROUND(([2024]-[2023])/[2023],2) AS 'GROWTH RATE'
FROM CTE0;

-- Số thương vong ở từng tháng giữa các năm và tỷ lệ tăng trưởng?
WITH CTE0 AS (
    SELECT 
        MONTH(DATE) AS MONTH,
        CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS FLOAT) AS '2023',
        CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS FLOAT) AS '2024'
    FROM traffic_accidents
    GROUP BY MONTH(DATE)
)
SELECT 
    MONTH,
    [2023],[2024],
    ROUND(([2024]-[2023])/[2023],2) AS 'GROWTH RATE'
FROM CTE0;


-- Tổng số ngày ghi nhận tai nạn có thương vong và không có thương vong
WITH CTE0 AS (
    SELECT 
        YEAR(DATE) AS YEAR,
        COUNT(DISTINCT(DATE)) AS 'Number of Days With Accidents'
    FROM traffic_accidents
    GROUP BY YEAR(DATE)
), CTE1 AS (
    SELECT 
        YEAR(DATE) AS YEAR,
        COUNT([ACCIDENT ID]) AS 'Number of Accidents With Casualties'
    FROM traffic_accidents
    WHERE [CASUALTIES] != 0
    GROUP BY YEAR(DATE)
), CTE2 AS (
    SELECT 
        YEAR(DATE) AS YEAR,
        COUNT([ACCIDENT ID]) AS 'Number of Accidents Without Casualties'
    FROM traffic_accidents
    WHERE [CASUALTIES] = 0
    GROUP BY YEAR(DATE)
)

SELECT 
    C0.YEAR,
    C0.[Number of Days With Accidents],
    C1.[Number of Accidents With Casualties],
    C2.[Number of Accidents Without Casualties]
FROM (CTE0 C0 JOIN CTE1 C1
    ON C0.YEAR = C1.YEAR) JOIN CTE2 C2 
        ON C0.YEAR = C2.YEAR;

-- Trung bình mỗi ngày / giờ có bao nhiêu người bị thương vong do tai nạn giao thông?
-- trung bình mỗi ngày
SELECT 
    ROUND(CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS FLOAT) / 365,0) AS '2023',
    ROUND(CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS FLOAT) / 366,0) AS '2024'
FROM traffic_accidents;

-- Trung bình mỗi giờ
SELECT 
    ROUND(CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS FLOAT) / (365*24),0) AS '2023',
    ROUND(CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS FLOAT) / (366*24),0) AS '2024'
FROM traffic_accidents;

-- Nguyên nhân gây tai nạn giao thông (Có nguyên nhân nào gia tăng hoặc giảm mạnh giữa 2 năm?)
WITH CTE0 AS (
    SELECT 
        CAUSE,
        CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS FLOAT) AS '2023',
        CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS FLOAT) AS '2024'
    FROM traffic_accidents
    GROUP BY CAUSE
)

SELECT
    CAUSE,
    [2023],
    [2024],
    ROUND((([2024] - [2023])/[2023])*100,2) AS 'GROWTH RATE'
FROM CTE0;

-- Phân vị số thương vong ở mỗi vụ tai nạn theo mỗi nguyên nhân
SELECT
    DISTINCT(CAUSE) AS CAUSE,
    PERCENTILE_DISC(0.25) WITHIN GROUP (ORDER BY CASUALTIES ASC) OVER (PARTITION BY CAUSE) AS [25TH],
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY CASUALTIES ASC) OVER (PARTITION BY CAUSE) AS [50TH],
    PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY CASUALTIES ASC) OVER (PARTITION BY CAUSE) AS [75TH]
FROM traffic_accidents
WHERE YEAR(DATE) = 2024 AND CASUALTIES != 0;


-- số vụ tai nạn và thương vong do yếu tố con người và tự nhiên
WITH CTE0 AS (
    SELECT 
        'Human' AS FACTOR,
        COUNT([ACCIDENT ID]) AS [ACCIDENTS],
        SUM(CASUALTIES) AS [CASUALTIES]
    FROM traffic_accidents
    WHERE CAUSE != 'WEATHER CONDITIONS'
    UNION
    SELECT 
        'Nature' AS FACTOR,
        COUNT([ACCIDENT ID]) AS [ACCIDENTS],
        SUM(CASUALTIES) AS [CASUALTIES]   
    FROM traffic_accidents
    WHERE CAUSE = 'WEATHER CONDITIONS'
)
SELECT 
    FACTOR,
    ROUND((CAST(ACCIDENTS AS FLOAT) / SUM(ACCIDENTS) OVER())*100,2) AS ACCIDENT,
    ROUND((CAST(CASUALTIES AS FLOAT) / SUM(CASUALTIES) OVER())*100,2) AS CASUALTIES
FROM CTE0;

--- Yếu tố tự nhiên (Mưa đá , bão và mưa)
-- Tháng nào cũng xảy ra tai nạn giao thông do các yếu tố tự nhiên trên?
SELECT
    [WEATHER CONDITION],
    COUNT(DISTINCT(MONTH(CASE WHEN YEAR(DATE) = 2023 THEN DATE ELSE 0 END))) AS 'NUMBER OF MONTHS 2023',
    COUNT(DISTINCT(MONTH(CASE WHEN YEAR(DATE) = 2024 THEN DATE ELSE 0 END))) AS 'NUMBER OF MONTHS 2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND ([WEATHER CONDITION] = 'HAIL' OR [WEATHER CONDITION] = 'RAIN' OR [WEATHER CONDITION] = 'STORM')
GROUP BY [WEATHER CONDITION];


---- Trung bình mỗi vụ tai nạn có bao nhiêu thương vong theo từng nguyên nhân?
WITH CTE0 AS (
    SELECT
        CAUSE,
        ROUND(SUM(CASUALTIES) / COUNT([ACCIDENT ID]),2) AS [AVG OF CASUALTIES PER ACCIDENT 23]
    FROM traffic_accidents
    WHERE YEAR(DATE) = 2023
    GROUP BY CAUSE
), CTE1 AS (
    SELECT
        CAUSE,
        ROUND(SUM(CASUALTIES) / COUNT([ACCIDENT ID]),2) AS [AVG OF CASUALTIES PER ACCIDENT 24]
    FROM traffic_accidents
    WHERE YEAR(DATE) = 2024
    GROUP BY CAUSE 
)
SELECT
    C0.CAUSE,
    C0.[AVG OF CASUALTIES PER ACCIDENT 23],
    C1.[AVG OF CASUALTIES PER ACCIDENT 24]
FROM CTE0 C0 JOIN CTE1 C1 
    ON C0.CAUSE = C1.CAUSE;

--- bảng tần số về số thương vong ở mỗi nguyên nhân
WITH CTE0 AS (
    SELECT
        CAUSE,
        (CASE 
            WHEN CASUALTIES BETWEEN 1 AND 3 THEN '1-3'
            WHEN CASUALTIES BETWEEN 4 AND 6 THEN '4-6'
            WHEN CASUALTIES BETWEEN 7 AND 10 THEN '7-10' END) AS RANGE,
        COUNT(*) AS FREQ
    FROM traffic_accidents
    WHERE YEAR(DATE) = 2023 AND CASUALTIES > 0
    GROUP BY CAUSE, (CASE 
                        WHEN CASUALTIES BETWEEN 1 AND 3 THEN '1-3'
                        WHEN CASUALTIES BETWEEN 4 AND 6 THEN '4-6'
                        WHEN CASUALTIES BETWEEN 7 AND 10 THEN '7-10' END)
)

SELECT
    CAUSE,
    [1-3],
    [4-6],
    [7-10]
FROM CTE0 AS SOURCE_TABLE
PIVOT(
    MAX(FREQ) FOR RANGE IN ([1-3],[4-6],[7-10])
) AS PIVOT_TABLE;

--- 80% số thương vong ở mỗi nguyên nhân là bao nhiêu?
SELECT
    DISTINCT(CAUSE) AS CAUSE,
    PERCENTILE_DISC(0.80) WITHIN GROUP (ORDER BY CASUALTIES ASC) OVER (PARTITION BY CAUSE) AS [80%]
FROM traffic_accidents
WHERE YEAR(DATE) = 2024

------ WEATHER CONDITION -- STORM
-- Tháng nào cũng xảy ra tai nạn do điều kiện thời tiết khắc nghiệt?
SELECT
    MONTH(DATE) AS MONTH,
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND [WEATHER CONDITION] = 'STORM'
GROUP BY MONTH(DATE)
ORDER BY MONTH(DATE);
-- Số vụ tai nạn thường xảy ra vào đầu - giữa - hay cuối tháng?
SELECT
    (CASE 
        WHEN DATEPART(DAY,DATE) BETWEEN 1 AND 10 THEN 'Beginning of the month'
        WHEN DATEPART(DAY,DATE) BETWEEN 11 AND 20 THEN 'Mid month'
            ELSE 'End of the month' END
    ) AS [POINT IN TIME],
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND[WEATHER CONDITION] = 'STORM'
GROUP BY CASE 
            WHEN DATEPART(DAY,DATE) BETWEEN 1 AND 10 THEN 'Beginning of the month'
            WHEN DATEPART(DAY,DATE) BETWEEN 11 AND 20 THEN 'Mid month'
                ELSE 'End of the month' END;


-- Mỗi nguyên nhân thời tiết gây tai nạn thì điều kiện đường xá nào phổ biến nhất và mức độ thương vong tương ứng?
WITH CTE0 AS
    (
        SELECT 
        [ROAD CONDITION],
        CAST(SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS FLOAT) AS 'CASUALTIES 2023',
        CAST(SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS FLOAT) AS 'CASUALTIES 2024'
    FROM traffic_accidents
    WHERE CAUSE = 'WEATHER CONDITIONS' AND[WEATHER CONDITION] = 'STORM'
    GROUP BY [ROAD CONDITION]
    )

SELECT 
    [ROAD CONDITION],
    ROUND(([CASUALTIES 2024] - [CASUALTIES 2023])/[CASUALTIES 2023],2) AS 'GROWTH RATE'
FROM CTE0

------ WEATHER CONDITION -- HAIL
-- Tháng nào cũng xảy ra tai nạn do điều kiện thời tiết khắc nghiệt?
SELECT
    MONTH(DATE) AS MONTH,
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND [WEATHER CONDITION] = 'HAIL'
GROUP BY MONTH(DATE);

-- Các vụ tai nạn do mưa đá thường xảy ra vào lúc mấy giờ?
SELECT 
    Time_,
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND [WEATHER CONDITION] = 'HAIL'
GROUP BY Time_;

-- Mỗi nguyên nhân thời tiết gây tai nạn thì điều kiện đường xá nào phổ biến nhất và mức độ thương vong tương ứng?
SELECT 
    [ROAD CONDITION],
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS 'ACCIDENTS IN 2023',
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS 'CASUALTIES IN 2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS 'ACCIDENTS IN 2024',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS 'CASUALTIES IN 2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND[WEATHER CONDITION] = 'HAIL'
GROUP BY [ROAD CONDITION];

------ WEATHER CONDITION -- RAIN
-- Tháng nào cũng xảy ra tai nạn do điều kiện thời tiết khắc nghiệt?
SELECT
    MONTH(DATE) AS MONTH,
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND [WEATHER CONDITION] = 'RAIN'
GROUP BY MONTH(DATE);

-- Số vụ tai nạn giao thông ở mỗi khung giờ do trời mưa
SELECT 
    Time_,
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS '2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS '2024'   
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND [WEATHER CONDITION] = 'RAIN' AND (DATEPART(WEEKDAY,DATE) = 1 OR DATEPART(WEEKDAY,DATE) = 2)
GROUP BY Time_;

-- Mỗi nguyên nhân thời tiết gây tai nạn thì điều kiện đường xá nào phổ biến nhất và mức độ thương vong tương ứng?
SELECT 
    [ROAD CONDITION],
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN 1 ELSE 0 END) AS 'ACCIDENTS IN 2023',
    SUM(CASE WHEN YEAR(DATE) = 2023 THEN CASUALTIES ELSE 0 END) AS 'CASUALTIES IN 2023',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN 1 ELSE 0 END) AS 'ACCIDENTS IN 2024',
    SUM(CASE WHEN YEAR(DATE) = 2024 THEN CASUALTIES ELSE 0 END) AS 'CASUALTIES IN 2024'
FROM traffic_accidents
WHERE CAUSE = 'WEATHER CONDITIONS' AND[WEATHER CONDITION] = 'RAIN'
GROUP BY [ROAD CONDITION]

