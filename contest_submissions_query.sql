/* PROBLEM :Julia conducted a  days of learning SQL contest. The start date of the contest was March 01, 2016 and the end date was March 15, 2016.

Write a query to print total number of unique hackers who made at least  submission each day (starting on the first day of the contest), and find the hacker_id and name of the hacker who made maximum number of submissions each day. If more than one such hacker has a maximum number of submissions, print the lowest hacker_id. The query should print this information for each day of the contest, sorted by the date.

NOTE:

Total number of unique hackers: For each day of the contest, find the number of unique hackers who made at least one submission on that day.

Hacker with maximum submissions each day: For each day of the contest, identify the hacker who made the maximum number of submissions on that day. If multiple hackers made the same maximum number of submissions, the hacker with the lowest hacker_id should be selected.

Sorting by date: The results should be sorted by the date of each day during the contest (March 1, 2016, to March 15, 2016).

INPUT FORMAT:

Hackers Table:
Hacker id - integer type
name - string type

Submission table:
submission_date -Date Type
submission_id - Integer Type
hacker_id -Integer Type
score -Integer Type
*/

SELECT 
    sb.submission_date, 
    total_hackers, 
    max_id, 
    name 
FROM 
    submissions sb 
JOIN (
    SELECT 
        submission_date, 
        COUNT(DISTINCT hacker_id) AS total_hackers 
    FROM (
        SELECT DISTINCT 
            submission_date, 
            hacker_id 
        FROM 
            submissions
    ) all_submissions 
    WHERE 
        NOT EXISTS (
            SELECT 1 
            FROM (
                SELECT DISTINCT 
                    submission_date 
                FROM 
                    submissions
            ) all_days 
            WHERE 
                all_days.submission_date <= all_submissions.submission_date 
                AND NOT EXISTS (
                    SELECT 1 
                    FROM 
                        submissions s 
                    WHERE 
                        s.hacker_id = all_submissions.hacker_id 
                        AND s.submission_date = all_days.submission_date
                )
        ) 
    GROUP BY 
        submission_date 
    ORDER BY 
        submission_date
) temptble ON temptble.submission_date = sb.submission_date
JOIN (
    SELECT 
        submission_date, 
        MIN(hacker_id) AS max_id 
    FROM (
        SELECT 
            submission_date, 
            hacker_id, 
            COUNT(submission_id) AS ctsb 
        FROM 
            submissions sb 
        GROUP BY 
            submission_date, 
            hacker_id 
        HAVING 
            COUNT(submission_id) = (
                SELECT 
                    MAX(count_sub) 
                FROM (
                    SELECT 
                        submission_date, 
                        hacker_id, 
                        COUNT(submission_id) AS count_sub 
                    FROM 
                        submissions 
                    GROUP BY 
                        submission_date, 
                        hacker_id
                ) a 
                WHERE 
                    a.submission_date = sb.submission_date
            )
    ) max_count_tb 
    GROUP BY 
        submission_date
) mxtb ON sb.submission_date = mxtb.submission_date
JOIN 
    hackers hc ON hc.hacker_id = mxtb.max_id 
GROUP BY 
    sb.submission_date, 
    max_id, 
    name 
ORDER BY 
    sb.submission_date;