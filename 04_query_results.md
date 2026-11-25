# CloudNine Systems — Milestone 2: Queries, Results and Interpretation

Data covers **H1 2026 (two full quarters, 1 Jan – 30 Jun 2026)**; the as-of date for open items is **15 Jul 2026**. SQL for every query is in `03_queries.sql` (SQLite 3). The database is `cloudnine.db`, built from `01_schema.sql` and `02_data.sql` with foreign-key enforcement on (`PRAGMA foreign_keys = ON;`). Results below come from running those queries on that database.

## Dataset size

| Table                |       Rows |
| -------------------- | ---------: |
| region               |          5 |
| availability_zone    |         12 |
| data_center          |         14 |
| staff                |         30 |
| resource_type        |         12 |
| resource_group       |         25 |
| resource             |        369 |
| resource_status_log  |        163 |
| client               |         18 |
| team                 |         42 |
| client_user          |        148 |
| billing_account      |         31 |
| project              |         91 |
| cost_allocation_rule |        143 |
| service              |         10 |
| rate                 |         60 |
| reservation          |        317 |
| reservation_change   |        157 |
| deployment           |        250 |
| deployment_resource  |        503 |
| resource_assignment  |        536 |
| deployment_event     |     10,570 |
| usage_record         |      7,390 |
| adjustment           |         75 |
| invoice              |        172 |
| **Total**            | **21,143** |

## Queries

### Q1. Revenue by region, Q1 vs Q2

**Interpretation:** Every region grew in Q2. **US East** is the largest region and grew from $176k to $297k (+69%). Asia Pacific grew the fastest in percentage terms ($8.8k → $41.4k), but from a very small base. EU Central earns $154k in Q2 from only 4 clients, so each client there matters a lot. _Use:_ decide where to add capacity next.

| region_name    | clients | q1_revenue | q2_revenue |
| -------------- | ------- | ---------- | ---------- |
| US East        | 8       | 176,281.62 | 297,351.31 |
| Canada Central | 5       | 104,509.64 | 170,992.53 |
| EU Central     | 4       | 101,187.53 | 154,393.78 |
| US West        | 6       | 90,265.26  | 137,897.34 |
| Asia Pacific   | 3       | 8,827.41   | 41,366.73  |

_5 rows_

### Q2. Monthly revenue and GPU share

**Interpretation:** Monthly revenue more than doubled, from $145k in January to $311k in June. GPU is the main driver: it went from 11% of revenue in January to 40% in June. _Use:_ GPU is the product to invest in.

| month   | total_revenue | gpu_revenue | gpu_pct |
| ------- | ------------- | ----------- | ------- |
| 2026-01 | 145,305       | 15,879      | 10.9    |
| 2026-02 | 153,942       | 16,041      | 10.4    |
| 2026-03 | 181,825       | 54,036      | 29.7    |
| 2026-04 | 217,542       | 63,153      | 29      |
| 2026-05 | 272,992       | 97,644      | 35.8    |
| 2026-06 | 311,467       | 125,589     | 40.3    |

_6 rows_

### Q3. Clients ranked by revenue after discount

**Interpretation:** The top 3 clients (Bluefin, Meridian, Danube) bring in about $531k, close to half of all revenue, so losing one would hurt. Marcus Bell manages 5 accounts, including the largest one. The startups at the bottom of the list add up to very little revenue. _Use:_ decide which clients to prioritise for retention.

| client_name                           | account_manager | discount_pct | net_revenue |
| ------------------------------------- | --------------- | ------------ | ----------- |
| Bluefin Capital Group                 | Marcus Bell     | 14           | 213,200     |
| Meridian Health Network               | Priya Raman     | 15           | 193,547     |
| Danube Versicherung AG                | Elena Vogel     | 11           | 123,843     |
| Rheinwerk Logistik GmbH               | Elena Vogel     | 11           | 86,025      |
| Lakeshore Provincial Digital Services | Priya Raman     | 12           | 79,539      |
| Harborview Retail Co.                 | Daniel Okafor   | 10           | 62,508      |
| Pinecrest Credit Union                | Priya Raman     | 6            | 61,679      |
| Northgate University                  | Marcus Bell     | 18           | 61,108      |
| Vireo Media Studios                   | Daniel Okafor   | 8            | 53,707      |
| Maplewood Health Clinics              | Marcus Bell     | 9            | 47,451      |
| Cascadia Game Works                   | Daniel Okafor   | 0            | 46,025      |
| Lumen Robotics                        | Mei Tan         | 5            | 25,243      |
| Tanjong Fintech Pte Ltd               | Mei Tan         | 4            | 21,303      |
| Kestrel Energy Solutions              | Marcus Bell     | 9            | 21,189      |
| Solenne Biotech                       | Elena Vogel     | 0            | 14,036      |
| Open Harbor Foundation                | Priya Raman     | 12           | 10,480      |
| Atlas Genomics                        | Daniel Okafor   | 5            | 5,182       |
| Brightpath Learning                   | Marcus Bell     | 0            | 2,575       |

_18 rows_

### Q4. Data center capacity reserved in Q2

**Interpretation:** The US East data centers are the busiest, at 53–63% of their capacity reserved. The two Singapore sites are only 16–27% reserved, so Asia Pacific has more hardware than it needs. _Use:_ move or delay hardware purchases away from under-used sites.

| dc_name   | resources | reserved_pct |
| --------- | --------- | ------------ |
| CN-ASH-01 | 29        | 63           |
| CN-NWK-01 | 22        | 59.1         |
| CN-RIC-01 | 24        | 53.5         |
| CN-ASH-02 | 25        | 52.8         |
| CN-HIL-01 | 39        | 49.5         |
| CN-TOR-01 | 34        | 47.6         |
| CN-MTL-01 | 43        | 44.3         |
| CN-MUC-01 | 15        | 43.8         |
| CN-FRA-01 | 26        | 43.4         |
| CN-FRA-02 | 21        | 39.6         |
| CN-RNO-01 | 35        | 33.3         |
| CN-BER-01 | 19        | 31.8         |
| CN-SIN-01 | 20        | 27.2         |
| CN-SIN-02 | 17        | 15.9         |

_14 rows_

### Q5. Outages by data center

**Interpretation:** **CN-MTL-01 (Montreal)** had 11 outages, almost twice as many as any other site. CN-ASH-01 and CN-SIN-01 had few outages but took the longest to repair (445 and 590 minutes on average). _Use:_ investigate hardware in Montreal, and add repair staff where fixes are slow.

| dc_name   | outages | outage_hours | avg_repair_minutes |
| --------- | ------- | ------------ | ------------------ |
| CN-MTL-01 | 11      | 33.8         | 185                |
| CN-NWK-01 | 6       | 22.1         | 221                |
| CN-RNO-01 | 5       | 22.7         | 272                |
| CN-ASH-02 | 5       | 18.9         | 227                |
| CN-HIL-01 | 4       | 18.7         | 280                |
| CN-TOR-01 | 3       | 6.6          | 132                |
| CN-FRA-02 | 3       | 13.8         | 277                |
| CN-ASH-01 | 3       | 22.3         | 445                |
| CN-SIN-01 | 2       | 19.6         | 590                |
| CN-RIC-01 | 2       | 14.3         | 428                |
| CN-MUC-01 | 1       | 2.9          | 175                |
| CN-FRA-01 | 1       | 1.6          | 95                 |

_12 rows_

### Q6. Failover recovery time

**Interpretation:** 36 outages were handled by moving the workload to a spare resource. Recovery took about 45–59 minutes on average and never more than 90 minutes. _Use:_ recovery is consistent, but adding spares closer to each zone could make it faster.

| category | failovers | avg_recovery_minutes | worst_recovery_minutes |
| -------- | --------- | -------------------- | ---------------------- |
| compute  | 23        | 52                   | 90                     |
| storage  | 5         | 45                   | 85                     |
| gpu      | 5         | 59                   | 90                     |
| network  | 3         | 52                   | 70                     |

_4 rows_

### Q7. SLA credits by client

**Interpretation:** Credits don't follow the number of outages. Meridian Health had 8 credits but received only $750, while Lumen Robotics received $2,281 for a single outage. That's because each credit is a percentage of the failed resource's price, and GPU nodes are expensive. _Use:_ review the SLA credit policy so credits match the client's actual impact.

| client_name                           | tier     | sla_credits | credit_total |
| ------------------------------------- | -------- | ----------- | ------------ |
| Lumen Robotics                        | silver   | 1           | 2,281.25     |
| Brightpath Learning                   | standard | 1           | 985.5        |
| Rheinwerk Logistik GmbH               | gold     | 2           | 940.24       |
| Meridian Health Network               | platinum | 8           | 750.45       |
| Maplewood Health Clinics              | gold     | 4           | 518.3        |
| Cascadia Game Works                   | standard | 1           | 401.5        |
| Lakeshore Provincial Digital Services | gold     | 4           | 356.24       |
| Pinecrest Credit Union                | silver   | 6           | 277.4        |
| Harborview Retail Co.                 | gold     | 5           | 264.63       |
| Northgate University                  | silver   | 1           | 175.2        |
| Vireo Media Studios                   | gold     | 3           | 167.54       |
| Bluefin Capital Group                 | platinum | 4           | 127.02       |
| Kestrel Energy Solutions              | gold     | 3           | 83.22        |
| Open Harbor Foundation                | standard | 1           | 15.33        |
| Tanjong Fintech Pte Ltd               | silver   | 1           | 13.87        |
| Danube Versicherung AG                | gold     | 1           | 6.94         |

_16 rows_

### Q8. Unpaid invoices by client (as of 15 Jul 2026)

**Interpretation:** Most of the money owed is June invoices that are not due yet. The real problem is **$24.4k past due** from three clients. **Cascadia Game Works** owes $13.1k past due, and its oldest invoice is 107 days late. _Use:_ send Cascadia to collections, and follow up with Lakeshore and Open Harbor.

| client_name                           | unpaid_invoices | owed      | past_due  | oldest_days_past_due |
| ------------------------------------- | --------------- | --------- | --------- | -------------------- |
| Cascadia Game Works                   | 5               | 24,408.15 | 13,121.92 | 107                  |
| Lakeshore Provincial Digital Services | 3               | 17,689.52 | 6,756.47  | 15                   |
| Open Harbor Foundation                | 2               | 7,152.91  | 4,543.21  | 15                   |
| Bluefin Capital Group                 | 2               | 33,380.91 | 0         | -15                  |
| Meridian Health Network               | 2               | 22,130    | 0         | -15                  |
| Northgate University                  | 1               | 20,399.32 | 0         | -15                  |
| Vireo Media Studios                   | 2               | 15,449.5  | 0         | -15                  |
| Rheinwerk Logistik GmbH               | 2               | 14,484.28 | 0         | -15                  |
| Danube Versicherung AG                | 2               | 12,737.57 | 0         | -15                  |
| Harborview Retail Co.                 | 2               | 9,198.98  | 0         | -15                  |
| Tanjong Fintech Pte Ltd               | 1               | 6,447.9   | 0         | -15                  |
| Maplewood Health Clinics              | 2               | 4,231.39  | 0         | -15                  |
| Kestrel Energy Solutions              | 1               | 2,421.34  | 0         | -15                  |
| Pinecrest Credit Union                | 2               | 1,838.37  | 0         | -15                  |
| Brightpath Learning                   | 1               | 991.16    | 0         | -15                  |
| Solenne Biotech                       | 1               | 262.63    | 0         | -15                  |

_16 rows_

### Q9. GPU hours by pricing model, before and after the April price change

**Interpretation:** Most GPU hours are on reserved contracts, so most GPU revenue was protected from the price change. Among pay-as-you-go users, Q1 usage was split evenly between peak and off-peak. In Q2, after peak prices went up, off-peak usage was about **twice** peak usage. _Use:_ off-peak pricing successfully moves demand to quieter hours.

| quarter | pricing_model | gpu_hours | revenue    |
| ------- | ------------- | --------- | ---------- |
| Q1      | off_peak      | 2,772     | 5,235.76   |
| Q1      | peak          | 2,766     | 7,878.82   |
| Q1      | reserved      | 23,015    | 72,841.43  |
| Q2      | off_peak      | 2,745     | 16,515.82  |
| Q2      | peak          | 1,415     | 13,129.76  |
| Q2      | reserved      | 60,154    | 259,010.02 |

_6 rows_

### Q10. Reservations by client type

**Interpretation:** 65 reservations were cancelled, and 41 of them were lost because there was **no capacity**, not because the client changed their mind. Most of those were enterprise bookings. Startups pay deposits and cancel the least. _Use:_ more capacity would directly recover lost enterprise bookings.

| client_type | reservations | cancelled | lost_to_capacity | avg_lead_days | deposits |
| ----------- | ------------ | --------- | ---------------- | ------------- | -------- |
| enterprise  | 246          | 51        | 30               | 20            | 0        |
| startup     | 35           | 5         | 4                | 22.3          | 22350    |
| government  | 13           | 0         | 0                | 18.8          | 0        |
| academic    | 12           | 4         | 2                | 18.5          | 0        |
| nonprofit   | 11           | 5         | 5                | 20.9          | 3600     |

_5 rows_

### Q11. Q2 cost charged to each billing account

**Interpretation:** Splits each project's Q2 usage across the client's billing accounts, using the allocation rule in effect at the time of use. For example, Bluefin's Corporate account carries $90k while its R&D account carries $44k. _Use:_ gives each client's finance team an internal cost report.

| account_name         | q2_cost   |
| -------------------- | --------- |
| Bluefin Corporate    | 89,923.01 |
| Northgate Central IT | 59,596.19 |
| Meridian Operations  | 50,798.94 |
| Rheinwerk R&D        | 45,159.62 |
| Bluefin R&D          | 43,608.55 |
| Meridian R&D         | 43,274.12 |
| Meridian Corporate   | 30,457.13 |
| Vireo Corporate      | 29,754.39 |
| Lakeshore R&D        | 29,302.72 |
| Danube Corporate     | 29,271.66 |
| Danube R&D           | 26,998.94 |
| Cascadia Corporate   | 26,384.53 |
| Harborview Corporate | 19,496.33 |
| Lakeshore Corporate  | 18,948.27 |
| Lumen Corporate      | 16,637.05 |
| Rheinwerk Corporate  | 16,522.63 |
| Pinecrest Corporate  | 15,705.64 |
| Tanjong Corporate    | 15,662.72 |
| Danube Operations    | 14,860.47 |
| Harborview R&D       | 14,657.12 |
| Vireo R&D            | 10,540.88 |
| Kestrel Corporate    | 10,386.45 |
| Open Corporate       | 9,922.15  |
| Maplewood R&D        | 9,038.13  |
| Maplewood Corporate  | 8,449.68  |
| Pinecrest Operations | 6,164.64  |
| Kestrel R&D          | 2,955.12  |
| Pinecrest R&D        | 2,467.20  |
| Solenne Corporate    | 1,425.09  |
| Brightpath Corporate | 991.16    |

_30 rows_

### Q12. Invoiced vs collected by month

**Interpretation:** January to April invoices are 97–100% paid. May is at 93% because of late payers. June looks low (12%) only because those invoices are not due until July 30. _Use:_ track how quickly clients pay.

| month   | invoices | invoiced   | collected  | collected_pct |
| ------- | -------- | ---------- | ---------- | ------------- |
| 2026-01 | 28       | 130,249.57 | 130,249.57 | 100           |
| 2026-02 | 27       | 136,888.93 | 132,770.03 | 97            |
| 2026-03 | 29       | 158,522.82 | 157,960.82 | 99.6          |
| 2026-04 | 29       | 196,221.48 | 193,670.77 | 98.7          |
| 2026-05 | 29       | 241,681.53 | 224,491.54 | 92.9          |
| 2026-06 | 30       | 191,098.1  | 22,295.77  | 11.7          |

_6 rows_

### Q13. Password use on confidential deployments

**Interpretation:** Every client with confidential deployments still has users acting with only a password instead of MFA or SSO, in 4–8% of their actions. Danube, Bluefin and Meridian have the most password actions. _Use:_ require MFA on confidential deployments.

| client_name                           | actions | password_actions | password_pct |
| ------------------------------------- | ------- | ---------------- | ------------ |
| Atlas Genomics                        | 24      | 2                | 8.3          |
| Danube Versicherung AG                | 992     | 65               | 6.6          |
| Harborview Retail Co.                 | 50      | 3                | 6            |
| Vireo Media Studios                   | 17      | 1                | 5.9          |
| Pinecrest Credit Union                | 646     | 38               | 5.9          |
| Lakeshore Provincial Digital Services | 617     | 36               | 5.8          |
| Bluefin Capital Group                 | 1088    | 58               | 5.3          |
| Meridian Health Network               | 1629    | 83               | 5.1          |
| Maplewood Health Clinics              | 408     | 20               | 4.9          |
| Tanjong Fintech Pte Ltd               | 238     | 11               | 4.6          |
| Solenne Biotech                       | 92      | 4                | 4.3          |
| Kestrel Energy Solutions              | 73      | 3                | 4.1          |

_12 rows_

### Q14. Incidents handled per staff member

**Interpretation:** Chloe Tremblay in Montreal handled the most incidents (12), which matches Montreal's outage problem in Q5. Singapore staff handled very few. _Use:_ add on-call support in Montreal.

| staff_member    | home_dc   | incidents_handled |
| --------------- | --------- | ----------------- |
| Chloe Tremblay  | CN-MTL-01 | 12                |
| Ethan Ross      | CN-RNO-01 | 9                 |
| Noah Becker     | CN-NWK-01 | 7                 |
| Julien Gagnon   | CN-TOR-01 | 7                 |
| Jenna Park      | CN-ASH-02 | 5                 |
| Fatima Haddad   | CN-HIL-01 | 5                 |
| Hamza Qureshi   | CN-RIC-01 | 3                 |
| Carlos Mendes   | CN-ASH-01 | 3                 |
| Owen Fitzgerald | CN-RIC-01 | 3                 |
| Anna Schmidt    | CN-FRA-01 | 3                 |
| Felix Wagner    | CN-FRA-02 | 3                 |
| Lukas Brandt    | CN-FRA-01 | 2                 |
| Wei Lim         | CN-SIN-01 | 2                 |
| Grace Liu       | CN-HIL-01 | 1                 |
| Aisha Bello     | CN-MTL-01 | 1                 |
| Leon Richter    | CN-MUC-01 | 1                 |
| Arjun Nair      | CN-SIN-02 | 1                 |

_17 rows_
