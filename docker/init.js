// Admin 데이터베이스 선택
db = db.getSiblingDB('Admin');

// 사용자 생성 및 권한 부여
db.createUser({
    user: 'Server',
    pwd: '1234',
    roles: [{ role: 'readWrite', db: 'Admin' }]
});
