from pyswip import Prolog
from query import Query

def read_from_file(name):
    """Reads text data from a file given a filename."""
    with open(name, 'r') as f:
        return f.read()

# Colors
CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
GRAY = "\033[1;30m"
END = "\033[0m"

# /help command
HELP = f'''
The following sentence patterns are guaranteed to be {GREEN}valid{END}:

{GRAY}Questions{END}
{read_from_file('patterns_questions.txt')}

{GRAY}Statements{END}
{read_from_file('patterns_statements.txt')}'''

print(f'Type {CYAN}/help{END} for a list of sentence patterns that are guaranteed to be valid.')
    
Prolog.consult('knowledge_base.pl')

while True:
    query_string = input('\n> ')
    query_obj = None

    if query_string == '/help':
        print(HELP)
        continue # Skip to the next input

    # Handle errors when parsing the input prompt
    try:
        query_obj = Query(query_string)
    except:
        print(f'{RED}Sorry, can you rephrase your prompt?\n{END}')
        continue # Skip to the next input

    prolog_query = query_obj.get_prolog_query()
    print(f'\n{CYAN}{prolog_query}{END}')

    # Handle assertions
    if query_obj.assertion:
        try:
            # Prolog.query() returns a generator that we iterate with next()
            # This will raise a StopIteration exception if safe_assertz/1 fails
            # Note we wrap the query in a call to safe_assertz/1
            next(Prolog.query(f'safe_assertz({prolog_query}).'))
            print(f'{GREEN}OK! I learned something.{END}')
        except Exception as e:
            print(f'{GRAY}{e}{END}')
            # Might be a better way of checking for this but I'm not sure
            if 'contradiction' in str(e):
                # Contradiction error
                print(f"{RED}That's impossible!{END}")
            else:
                # Unknown predicate error
                print(f'{RED}Sorry, can you rephrase your prompt?{END}')

    # Handle open-ended questions
    elif query_obj.marker.lower() == 'who':
        try:
            result = ', '.join(
                # Create a set to remove duplicates
                set([item
                    # Iterate over entries in the result list
                    for entry in list(Prolog.query(prolog_query))
                    for item in (
                        # If entry is a sublist, iterate over that list
                        [nested_entry.capitalize() 
                            for nested_entry in entry.get('X')]
                            if isinstance(entry.get('X'), list)
                        # If entry is not a sublist, get the value directly
                        # We wrap it in an array for the outer for-in
                        else [entry.get('X').capitalize()] 
                    )
                ])
            )
            if result:
                print(f'{GREEN}{result}{END}')
            else:
                print(f"{RED}Couldn't find anyone.{END}")
        except Exception as e:
            print(f'{GRAY}{e}{END}')
            print(f'{RED}Sorry, can you rephrase your prompt?{END}')

    # Handle Boolean queries
    else:
        try:
            # Wrap query around once/1, but not sure if this even does anything
            # "If the query is a yes/no question, returns {} for yes, and
            # nothing for no"
            if list(Prolog.query(f'once({prolog_query}).')):
                print(f'{GREEN}Yes!{END}')
            else:
                print(f'{RED}No{END}')
        except Exception as e:
            print(f'{GRAY}{e}{END}')
            print(f'{RED}Sorry, can you rephrase your prompt?{END}')