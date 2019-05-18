-- build customer key
select 
    lower(name), 
    regexp_replace(name, '[^a-zA-Z0-9]+', ''),
    lower(regexp_replace(name, '[^a-zA-Z0-9]+', '')) as CustKey
from clients

-- parse out the quote from the url
select 
    name, 
    summaryquote, 
    parse_url(summaryquote,'PATH'),
    locate('/',parse_url(summaryquote,'PATH'),2),
    substring(parse_url(summaryquote,'PATH'),9,4),
    substring(
        parse_url(summaryquote,'PATH'),
        locate('/',parse_url(summaryquote,'PATH'),2)+1
        ,4
    ) as symbol
from clients

-- combine the two for a new customer key
select 
    name, 
    concat(
        lower(regexp_replace(name, '[^a-zA-Z0-9]+', '')),
        '-',
        substring(parse_url(summaryquote,'PATH'),9,4)
    ) as CustKey
from clients
