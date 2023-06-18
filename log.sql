-- Keep a log of any SQL queries you execute as you solve the mystery.

-- list of tables:
-- crime_scene_reports: day, time, year, street, description of incident of crime
-- interviews: there is a transcript for the interview
-- atm_transactions: transactions from a bank
-- bank_accounts: identify the person bank account
-- airports: types of airport to go to
-- flights: origin location of flights, day/time of flight
-- passengers: who was on which flight;
-- phone_calls: contains information on caller/reciever, day/time happening, and duration of call
-- people: contains information on person's name, phone number, passport, and license plate
-- bakery_security_logs: must be a security logs that contain information of crime


-- Who the thief’s accomplice is who helped them escape
-- All you know is that the theft took place on July 28, 2021 and that it took place on Humphrey Street.


-- check crime_scene_reports that occurred on July 28, 2021 at Humphrey Street
SELECT *
FROM crime_scene_reports
WHERE year = 2021
    AND month = 7
    AND day = 28
    AND street = 'Humphrey Street';
-- after running the query; description says: Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery. Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.
-- id is 295


-- check transcipt for the interviews
SELECT interviews.*
FROM interviews
WHERE year = 2021
    AND month = 7
    AND day = 28;

-- helpful output:
-- id 161; Ruth; Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time
-- id 162; Eugene; I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money
-- id 163; Raymond; As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
--      The thief then asked the person on the other end of the phone to purchase the flight ticket
-- id 193; Emma; I'm the bakery owner, and someone came in, suspiciously whispering into a phone for about half an hour. They never bought anything.

-- 3 people were interview; maybe only id 161, 162, and 163 are the most helpful




-- check out id 161; the security camera footage in the parking lot that exit and happened within 10 minutes; accident happened at 10:15; so increment 10 minute more to be less than or equal to 25
SELECT bakery_security_logs.*
FROM bakery_security_logs
WHERE year = 2021
    AND month = 7
    AND day = 28
    AND activity = 'exit'
    AND hour BETWEEN 9 AND 11
    AND minute <= 25;


-- get people that exit on that day
SELECT DISTINCT people.name
, people.passport_number
, people.phone_number
, people.license_plate
FROM people
INNER JOIN bakery_security_logs s on people.license_plate = s.license_plate
WHERE s.year = 2021
    AND s.month = 7
    AND s.day = 28
    AND s.activity = 'exit'
    AND s.minute <=25
    AND s.hour BETWEEN 9 and 10;

-- possibe suspect: Vannessa, Bruce, Barry, Luca, Sofia, Iman, Diana, and Kelsey

-- check out id 162; someone withdrawing money at an ATM on Legett Street
SELECT atm_transactions.*
FROM atm_transactions
WHERE year = 2021
    AND month = 7
    AND day = 28
    AND atm_location = 'Leggett Street'
    AND transaction_type = 'withdraw';


-- i think you can connect atm_transaction of account_number to bank_accounts account_number
-- then connect person_id from bank_accounts to id in the people table; it is someone withdrawing money before 10:15
SELECT people.*
, t.*
FROM people
INNER JOIN bank_accounts b ON people.id = b.person_id
INNER JOIN atm_transactions t ON b.account_number = t.account_number
WHERE   t.year = 2021
    AND t.month = 7
    AND t.day = 28
    AND t.atm_location = 'Leggett Street'
    AND t.transaction_type = 'withdraw';




-- want to find out the person that withdraw money and exit on that day 7/28/2021
SELECT people.*
FROM people
INNER JOIN bank_accounts b ON people.id = b.person_id
INNER JOIN atm_transactions t ON b.account_number = t.account_number
INNER JOIN bakery_security_logs s ON people.license_plate = s.license_plate
WHERE   t.year = 2021
    AND t.month = 7
    AND t.day = 28
    AND t.atm_location = 'Leggett Street'
    AND t.transaction_type = 'withdraw'
    AND s.activity = 'exit'
    AND s.minute <= 25
    AND s.hour BETWEEN 9 and 10;


-- More confident that the answer should be either Bruce, Diana, Iman, or Luca



-- check case 3; id 163
SELECT *
FROM phone_calls
WHERE year = 2021
    AND month = 7
    AND day = 28
    AND duration < 60;



-- find out who is flying out of fiftyville tomorrow
SELECT DISTINCT people.*
, a.full_name
, f.year
, f.month
, f.day
, f.hour
, f.minute
FROM people
INNER JOIN passengers p ON people.passport_number = p.passport_number
INNER JOIN flights f ON p.flight_id = f.id -- check passengers table
INNER JOIN airports a ON f.origin_airport_id = a.id
WHERE f.year =2021
    AND f.month = 7
    AND f.day = 29 -- the flight is happening tomorrow
    AND f.hour = 8; -- earliest flight happen at 8


-- Possible answer; Doris, Sofia, Bruce, Edward, Kelsey, Taylor, Kenny or Luca



-- answer has to be either Bruce or Luca; still have not take into account phone call
-- Bruce number is (367) 555-5533
-- Luca number is (389) 555-5198

SELECT *
FROM people
WHERE people.name = 'Bruce'
OR people.name = 'Luca';

-- check Bruce phone call
SELECT *
FROM phone_calls
WHERE phone_calls.caller = '(367) 555-5533';

--check Luca phone call
SELECT *
FROM phone_calls
WHERE phone_calls.caller = '(389) 555-5198';

-- Bruce is the answer; person on the other line number is (375) 555-8161


-- find out where Bruce is flying too
SELECT people.name
, f.*
FROM people
INNER JOIN passengers p ON people.passport_number = p.passport_number
INNER JOIN flights f ON p.flight_id = f.id
WHERE people.name = 'Bruce';

SELECT f.destination_airport_id
, airports.*
FROM flights f
INNER JOIN airports ON f.destination_airport_id = airports.id
WHERE f.destination_airport_id = 4;



-- who helped out Bruce
SELECT *
FROM people
WHERE phone_number = '(375) 555-8161';















