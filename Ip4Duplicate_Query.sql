USE Ip4Duplicate;
Go

SELECT 
	 s.id AS source_id, s.account AS source_account, s.ip_value AS source_ip
	,t.id AS target_id, t.account AS target_account, t.ip_value AS target_ip
	,CASE	WHEN s.is_range = 0 AND t.is_range = 0 THEN 
				  'Duplicate IP'
				+ CASE	WHEN s.account = t.account THEN ', Same Account' ELSE ', Different Account' END
			ELSE 
				  CASE	WHEN s.o1_lb = t.o1_lb AND s.o2_lb = t.o2_lb AND s.o3_lb = t.o3_lb AND s.o4_lb = t.o4_lb AND
							 s.o1_ub = t.o1_ub AND s.o2_ub = t.o2_ub AND s.o3_ub = t.o3_ub AND s.o4_ub = t.o4_ub
								THEN 'Duplicate Range'
						WHEN (s.o1_lb BETWEEN t.o1_lb AND t.o1_ub) AND (s.o2_lb BETWEEN t.o2_lb AND t.o2_ub) AND (s.o3_lb BETWEEN t.o3_lb AND t.o3_ub) AND (s.o4_lb BETWEEN t.o4_lb AND t.o4_ub) AND
							 (s.o1_ub BETWEEN t.o1_lb AND t.o1_ub) AND (s.o2_ub BETWEEN t.o2_lb AND t.o2_ub) AND (s.o3_ub BETWEEN t.o3_lb AND t.o3_ub) AND (s.o4_ub BETWEEN t.o4_lb AND t.o4_ub)
								THEN 'Encapsulated Range (S in T)'
						WHEN (t.o1_lb BETWEEN s.o1_lb AND s.o1_ub) AND (t.o2_lb BETWEEN s.o2_lb AND s.o2_ub) AND (t.o3_lb BETWEEN s.o3_lb AND s.o3_ub) AND (t.o4_lb BETWEEN s.o4_lb AND s.o4_ub) AND
							 (t.o1_ub BETWEEN s.o1_lb AND s.o1_ub) AND (t.o2_ub BETWEEN s.o2_lb AND s.o2_ub) AND (t.o3_ub BETWEEN s.o3_lb AND s.o3_ub) AND (t.o4_ub BETWEEN s.o4_lb AND s.o4_ub)
								THEN 'Encapsulated Range (T in S)'
						ELSE 'Overlapped Range' END

				+ CASE	WHEN s.account = t.account THEN ', Same Account' ELSE ', Different Account' END
	END AS Compare_Scenario
FROM 
			dbo.ip4 s					-- source
INNER JOIN	dbo.ip4 t ON s.id <> t.id	-- target
WHERE
		s.is_valid = 1 
	AND t.is_valid = 1
	AND	  (((s.o1_lb BETWEEN t.o1_lb AND t.o1_ub) AND (s.o2_lb BETWEEN t.o2_lb AND t.o2_ub) AND (s.o3_lb BETWEEN t.o3_lb AND t.o3_ub) AND (s.o4_lb BETWEEN t.o4_lb AND t.o4_ub))
		OR ((s.o1_ub BETWEEN t.o1_lb AND t.o1_ub) AND (s.o2_ub BETWEEN t.o2_lb AND t.o2_ub) AND (s.o3_ub BETWEEN t.o3_lb AND t.o3_ub) AND (s.o4_ub BETWEEN t.o4_lb AND t.o4_ub))
		OR ((t.o1_lb BETWEEN s.o1_lb AND s.o1_ub) AND (t.o2_lb BETWEEN s.o2_lb AND s.o2_ub) AND (t.o3_lb BETWEEN s.o3_lb AND s.o3_ub) AND (t.o4_lb BETWEEN s.o4_lb AND s.o4_ub))
		OR ((t.o1_ub BETWEEN s.o1_lb AND s.o1_ub) AND (t.o2_ub BETWEEN s.o2_lb AND s.o2_ub) AND (t.o3_ub BETWEEN s.o3_lb AND s.o3_ub) AND (t.o4_ub BETWEEN s.o4_lb AND s.o4_ub))
		)
--ORDER BY 
--	s.ip_value, t.ip_value
GO
