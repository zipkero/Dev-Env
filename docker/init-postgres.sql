-- 데이터베이스 생성
CREATE DATABASE Admin;

-- 사용자 생성
DO
$$
BEGIN
   IF NOT EXISTS (
      SELECT
      FROM   pg_catalog.pg_user
      WHERE  usename = 'Server') THEN

      CREATE ROLE "Server" LOGIN PASSWORD '1234';
   END IF;
END
$$;

-- 권한 부여
GRANT ALL PRIVILEGES ON DATABASE "Admin" TO "Server";
