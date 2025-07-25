import re

with open('knowledge_base.pl', 'r') as f:
    source = f.read()

# Remove multiline comments (/* */)
source = re.sub(r'/\*.*?\*/', '', source, flags=re.DOTALL)

# Remove single-line comments (%)
source = re.sub(r'%.*?$', '', source, flags=re.MULTILINE)

# 
rules = source.split('\n\n')

# Collapse into a single line and strip whitespace
rules = [re.sub(r'\s+', ' ', rule).strip(' .') for rule in rules if rule]

def wrap_predicates(str):
    return re.sub(
        r'([\w\\]+)\(',
        r'\\text{\1}(',
        str
    )

def parse_fact_predicates(str):
    return re.sub(
        r'\\text{fact\\_(\w+)}\((.*)\)',
        r'\\text{\1}_\\text{fact}(\2)',
        str
    )

for rule in rules:
    clauses = [clause.strip().replace('_', '\_')
               for clause in rule.split(':-')]

    head = clauses[0] if clauses[0] else 'False'
    tail = clauses[1] if clauses[1] else 'True'

    head = wrap_predicates(head)
    head = parse_fact_predicates(head)

    tail = wrap_predicates(tail)
    tail = parse_fact_predicates(tail)

    tail = tail.replace('),', ') \\land')
    tail = tail.replace(';', ' \\lor')
    tail = tail.replace('\\+', '\\neg')
    tail = tail.replace('\\==', '\\neq')
    tail = tail.replace('==', '=')

    print( # Print each rule
f'''\\begin{{equation}}
    {head} \impliedby {tail}
\\end{{equation}}''')

    print()