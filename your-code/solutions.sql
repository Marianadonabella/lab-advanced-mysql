-- In this challenge you'll find out who are the top 3 most profiting authors 
use publications;
-- Calculate the royalty of each sale for each author and the advance for each author and publication.
-- Write a SELECT query to obtain the following output:
-- Title ID
-- Author ID
-- Advance of each title and author
-- The formula is:
-- advance = titles.advance * titleauthor.royaltyper / 100
-- Royalty of each sale
-- The formula is:
-- sales_royalty = titles.price * sales.qty * titles.royalty / 100 * titleauthor.royaltyper / 100
-- Note that titles.royalty and titleauthor.royaltyper are divided by 100 respectively because they are percentage numbers instead of floats.
-- In the output of this step, each title may appear more than once for each author. This is because a title can have more than one sale
select ta.au_id, ta.title_id, t.advance * ta.royaltyper / 100 AS advance, t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
from titleauthor ta
left join titles t
on t.title_id = ta.title_id
left join sales s
on t.title_id = s.title_id;

--  2: Aggregate the total royalties for each title and author
-- Using the output from Step 1, write a query, containing a subquery, to obtain the following output:
-- Title ID
-- Author ID
-- Aggregated royalties of each title for each author
-- Hint: use the SUM subquery and group by both au_id and title_id
-- In the output of this step, each title should appear only once for each author.
select a.au_id, a.title_id, sum(a.sales_royalty) as total_royalties, a.advance
from(
select ta.au_id, ta.title_id, t.advance * ta.royaltyper / 100 AS advance, t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
from titleauthor ta
left join titles t
on t.title_id = ta.title_id
left join sales s
on t.title_id = s.title_id) a
group by a.au_id,a.title_id;

-- 3: Calculate the total profits of each author
-- Now that each title has exactly one row for each author where the advance and royalties are available, we are ready to obtain the eventual output. 
-- Using the output from Step 2, write a query, containing two subqueries, to obtain the following output:
-- Author ID
-- Profits of each author by aggregating the advance and total royalties of each title
-- Sort the output based on a total profits from high to low, and limit the number of rows to 3
select b.au_id, b.total_royalties + b.advance as profit
from(
select a.au_id, a.title_id, sum(a.sales_royalty) as total_royalties, a.advance
from(
select ta.au_id, ta.title_id, t.advance * ta.royaltyper / 100 AS advance, t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
from titleauthor ta
left join titles t
on t.title_id = ta.title_id
left join sales s
on t.title_id = s.title_id) a
group by a.au_id,a.title_id) b
order by profit desc
limit 3;

-- Challenge 2 - Alternative Solution
CREATE TEMPORARY TABLE adv_royalty
select ta.au_id, ta.title_id, t.advance * ta.royaltyper / 100 AS advance, t.price * s.qty * t.royalty / 100 * ta.royaltyper / 100 AS sales_royalty
from titleauthor ta
left join titles t
on t.title_id = ta.title_id
left join sales s
on t.title_id = s.title_id;

CREATE TEMPORARY TABLE adv_royalty_ta
select ar.au_id, ar.title_id, sum(ar.sales_royalty) as total_royalties, ar.advance
from adv_royalty ar
group by ar.au_id,ar.title_id;

select art.au_id, art.total_royalties + art.advance as profit
from adv_royalty_ta art
order by profit desc
limit 3;

-- Elevating from your solution in Challenge 1 & 2, create a permanent table named most_profiting_authors
-- to hold the data about the most profiting authors. The table should have 2 columns:
-- au_id - Author ID
-- profits - The profits of the author aggregating the advances and royalties

CREATE TABLE most_profiting_authors as
select art.au_id, art.total_royalties + art.advance as profit
from adv_royalty_ta art;
SELECT * FROM most_profiting_authors;

