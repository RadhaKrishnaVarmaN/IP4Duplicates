USE Ip4Duplicate;
Go

INSERT INTO dbo.ip4
(
	account, ip_value, is_valid, is_range, o1_lb, o1_ub, o2_lb, o2_ub, o3_lb, o3_ub, o4_lb, o4_ub, comment
)
SELECT 
	account='A1', ip_value, is_valid, is_range, o1_lb, o1_ub, o2_lb, o2_ub, o3_lb, o3_ub, o4_lb, o4_ub, comment
FROM (VALUES 
  ('1.1.0.0')
, ('1.1.1.*')
, ('1.1.2.1-7')
, ('1.1.3-7.*')
, ('1.1.8.0-255')
) AS tv(ip_value)
CROSS APPLY dbo.fn_ip4(tv.ip_value) b
GO
