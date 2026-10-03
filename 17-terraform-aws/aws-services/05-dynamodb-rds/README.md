# DynamoDB and RDS - Database Services

## DynamoDB

DynamoDB is a managed NoSQL key-value/document database. **Tables** contain **items**, and items contain typed **attributes**. The required **partition key** determines data distribution; an optional **sort key** orders related items and enables range queries. Capacity can be on-demand or provisioned. Common uses include sessions, carts, device state, metadata and high-scale serverless workloads. Good designs choose access patterns first, distribute partition keys, use secondary indexes deliberately, enable point-in-time recovery and avoid scans.

## RDS

RDS manages relational engines including PostgreSQL, MySQL, MariaDB, Oracle, SQL Server and Amazon Aurora. A **DB instance/cluster** supplies compute and storage. Security uses private subnets, Security Groups, encryption, IAM where supported and managed credentials. Automated backups support point-in-time recovery. **Multi-AZ** improves availability through a synchronous standby; it is not primarily a read-scaling feature. **Read replicas** asynchronously copy data for read scaling or disaster-recovery patterns. Common uses include transactional systems, relational reporting and applications requiring joins, constraints and SQL.
