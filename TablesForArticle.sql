--==========================================================
-- Author: Logan King
-- Date Created: 1/16/2020
-- Description: Queries for Titans Decision Making Article
--==========================================================

USE Foot_NFL_Tecmo
--4th downs ==================================================================================================
SELECT '4th Down Attempts from Opposing Side of Field' AS Title
SELECT CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END AS Team,
		CAST(CAST(SUM(CASE WHEN E.EventType=3 
		THEN (CASE WHEN K.ActionType=6 THEN 1 ELSE 0 END) ELSE 0 END)*100.0/
		COUNT(E.EventID) AS DECIMAL(10,2)) AS VARCHAR(5))+'%' AS FG_pct,
		CAST(CAST((SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN P.ActionType=7 THEN 1 ELSE 0 END) ELSE 0 END)+
		SUM(CASE WHEN E.EventType<>3 THEN 1 ELSE 0 END))*100.0/COUNT(E.EventID) AS DECIMAL(10,2)) 
		AS VARCHAR(5))+'%' AS No_FG_pct,
		COUNT(E.EventID) AS Events
FROM Events E
LEFT JOIN GameInfo GI
	ON E.GameID=GI.GameId
LEFT JOIN Kicking K
	ON E.GameID=K.GameId
	AND E.EventID=K.EventId
LEFT JOIN Punting P
	ON E.GameID=P.GameID
	AND E.EventID=P.EventId
WHERE E.Down=4 AND E.FieldPos<>E.OffensiveTeamId AND GI.Season=2019 
	AND E.YardageNegated=0 AND E.EventType NOT IN (0,5)
GROUP BY CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END

SELECT '4th Down and > 3 from Opposing Side of Field' AS Title
SELECT CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END AS Team,
		CAST(CAST(SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN K.ActionType=6 THEN 1 ELSE 0 END) ELSE 0 END)*100.0/
		COUNT(E.EventID) AS DECIMAL(10,2)) AS VARCHAR(5))+'%' AS FG_pct,
		CAST(CAST((SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN P.ActionType=7 THEN 1 ELSE 0 END) ELSE 0 END)+
		SUM(CASE WHEN E.EventType<>3 THEN 1 ELSE 0 END))*100.0/COUNT(E.EventID) AS DECIMAL(10,2)) 
		AS VARCHAR(5))+'%' AS No_FG_pct,
		COUNT(E.EventID) AS Events
FROM Events E
LEFT JOIN GameInfo GI
	ON E.GameID=GI.GameId
LEFT JOIN Kicking K
	ON E.GameID=K.GameId
	AND E.EventID=K.EventId
LEFT JOIN Punting P
	ON E.GameID=P.GameID
	AND E.EventID=P.EventId
WHERE E.Down=4 AND E.FieldPos<>E.OffensiveTeamId AND GI.Season=2019 
	AND E.YardageNegated=0 AND E.EventType NOT IN (0,5) AND E.ToGo>3
GROUP BY CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END 

SELECT '4th Down Play Calling Comparison' AS Title
SELECT CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END AS Team,
		CASE WHEN E.FieldPos<>E.OffensiveTeamId 
		THEN (CASE WHEN E.StartYard <=20 THEN 'Inside RZ' ELSE 'Outside RZ, Opposing Side of Field' END)
		ELSE 'Own Side of Field' END AS Field_Position,
		CAST(CAST((SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN K.ActionType=6 THEN 1 ELSE 0 END) ELSE 0 END)+
		SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN P.ActionType=7 THEN 1 ELSE 0 END) ELSE 0 END))*100.0/
		COUNT(E.EventID) AS DECIMAL(10,2)) AS VARCHAR(5))+'%' AS Not_Go_For_It_pct,
		CAST(CAST(SUM(CASE WHEN E.EventType<>3 THEN 1 ELSE 0 END)*100.0/COUNT(E.EventID) AS DECIMAL(10,2)) 
		AS VARCHAR(5))+'%' AS Go_For_It_Pct,
		CAST(SUM(E.ToGo)*1.0/COUNT(E.EventID) AS DECIMAL(5,2)) AS Avg_Ytg,
		COUNT(E.EventID) AS Events
FROM Events E
LEFT JOIN GameInfo GI
	ON E.GameID=GI.GameId
LEFT JOIN Kicking K
	ON E.GameID=K.GameId
	AND E.EventID=K.EventId
LEFT JOIN Punting P
	ON E.GameID=P.GameID
	AND E.EventID=P.EventId
WHERE E.Down=4 AND GI.Season=2019 
	AND E.YardageNegated=0 AND E.EventType NOT IN (0,5)
GROUP BY CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END,
	CASE WHEN E.FieldPos<>E.OffensiveTeamId 
	THEN (CASE WHEN E.StartYard <=20 THEN 'Inside RZ' ELSE 'Outside RZ, Opposing Side of Field' END)
	ELSE 'Own Side of Field' END 
ORDER BY Team, Field_Position

--============================================================================================================

--3rd Downs===================================================================================================
SELECT '3rd Down Play Calling Comparison' AS Title
SELECT CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END AS Team,
		CASE WHEN E.FieldPos<>E.OffensiveTeamId 
		THEN (CASE WHEN E.StartYard <=20 THEN 'Inside RZ' ELSE 'Outside RZ, Opposing Side of Field' END)
		ELSE 'Own Side of Field' END AS Field_Position,
		CAST(CAST((SUM(CASE WHEN MRu.RunType NOT IN (9,17,20) THEN 1 ELSE 0 END)+
		SUM(CASE WHEN MRe.TargetType=10 THEN 1 ELSE 0 END))*100.0/COUNT(E.EventID) AS DECIMAL(10,2)) 
		AS VARCHAR(5))+'%' AS Run_Pct,
		CAST(CAST((COUNT(MPE.Attempt)-SUM(CASE WHEN MRe.TargetType=10 THEN 1 ELSE 0 END)+
		SUM(CASE WHEN MRu.RunType IN (9,17,20) THEN 1 ELSE 0 END))*100.0/COUNT(E.EventID) AS DECIMAL(10,2)) 
		AS VARCHAR(5))+'%' AS Pass_Pct,
		CAST(SUM(E.ToGo)*1.0/COUNT(E.EventID) AS DECIMAL(5,2)) AS Avg_Ytg,
		COUNT(E.EventID) AS Events
FROM Events E
LEFT JOIN GameInfo GI
	ON E.GameID=GI.GameId
LEFT JOIN MergedRushingEvents MRu
	ON E.GameID=MRu.GameId
	AND E.EventID=MRu.EventId
LEFT JOIN MergedPassingEvents MPE
	ON E.GameID=MPE.GameId
	AND E.EventID=MPE.EventId
LEFT JOIN MergedReceivingEvents MRe
	ON E.GameID=MRe.GameId
	AND E.EventID=MRe.EventId
WHERE E.Down=3 AND GI.Season=2019
	AND E.YardageNegated=0 AND E.EventType NOT IN (0,5)
	AND(MRu.Carries=1 OR (MPE.Attempt IS NOT NULL) OR MRe.Target=1)
GROUP BY CASE E.OffensiveTeamId WHEN 31 THEN 'Titans' ELSE 'Rest of NFL' END,
	CASE WHEN E.FieldPos<>E.OffensiveTeamId  
	THEN (CASE WHEN E.StartYard <=20 THEN 'Inside RZ' ELSE 'Outside RZ, Opposing Side of Field' END)
	ELSE 'Own Side of Field' END
ORDER BY Team, Field_Position
--============================================================================================================

--TD/FG Ratio Stats===========================================================================================
--Temporary table for all season
SELECT T.Abbr, GI.Season, GI.Week, 
	SUM(CASE WHEN E.EventType=3 THEN (CASE WHEN K.ActionType=6 THEN 1 ELSE 0 END) ELSE 0 END) AS FGA,
	SUM(CAST(E.FieldGoal AS INT)) as FGM, SUM(CAST(E.Touchdown AS INT)) as TD
INTO #All_score_tab
FROM Events E
LEFT JOIN GameInfo GI
	ON E.GameID=GI.GameId
LEFT JOIN Kicking K
	ON E.GameID=K.GameId
	AND E.EventID=K.EventId
LEFT JOIN Punting P
	ON E.GameID=P.GameID
	AND E.EventID=P.EventId
LEFT JOIN Teams T
	ON E.OffensiveTeamId=T.TeamId
WHERE E.YardageNegated=0 AND E.EventType NOT IN (0,5) AND GI.Season IS NOT NULL
Group by T.Abbr, GI.Season, GI.Week

SELECT 'Scoring Ratio Chart' AS Title
SELECT Abbr, Season, SUM(FGM) AS FGM, SUM(FGA) AS FGA, SUM(FGM)*1.0/SUM(FGA) AS FGpct, SUM(TD) AS TD, 
	SUM(TD)*1.0/SUM(FGA) AS TD_FGA_ratio, SUM(TD)*1.0/SUM(FGM) AS TD_FGM_ratio 
FROM #All_score_tab 
GROUP BY Abbr, Season 
ORDER BY TD_FGM_ratio DESC

SELECT 'Tennessee 2019 Scoring Splits' AS Title
SELECT CASE WHEN Week>=9 THEN 'Week 9+' ELSE 'Weeks 1-8' END AS Timeframe, 
	SUM(FGM) AS FGM, SUM(FGA) AS FGA, SUM(TD) AS TD 
FROM #All_score_tab WHERE Abbr='TEN' AND Season=2019 
GROUP BY CASE WHEN Week>=9 THEN 'Week 9+' ELSE 'Weeks 1-8' END