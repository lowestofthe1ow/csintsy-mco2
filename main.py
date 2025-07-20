from pyswip import Prolog, Functor, call
import re

Prolog.consult('knowledge_base.pl')

CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
GRAY = "\033[1;30m"
END = "\033[0m"

class Query:
    def __init__(self, query_string):
        """Creates a new Query instance given a natural-language prompt.""" 

        # Private attribute/s ==================================================
        self._args_left = []   # Arguments before the predicate
        self._args_right = []  # Arguments after the predicate
        self._predicate = []   # Predicate name
        #=======================================================================

        # Public attribute/s ===================================================
        self.marker = ''       # Question marker ('are', 'is', 'who')
        self.assertion = False # Whether the query is an assertion of a fact
        #=======================================================================

        # Split the prompt into words, stripping them of certain characters
        words = [word.strip('.,?') for word in query_string.split()]

        # The first word is the question marker
        self.marker = words.pop(0)

        # Questions that start with 'who' are open-ended
        if self.marker.lower() == 'who':
            # 'X' is a placeholder for use in Prolog
            self._args_left.append('X')

        # If the query starts with 'is' or 'are', then it is closed-ended.
        # Otherwise, it is an assertion of a fact.
        elif self.marker.lower() not in ['is', 'are']:
            self.assertion = True
            words = [self.marker] + words # Put first word back in the list
            self._predicate.append('fact') # Add "fact_" tag to assertions

        # Tracks whether we've encountered the predicate
        found_predicate = False 

        # Process the query word for word
        for word in words:
            # Ignore these words
            if word in ['a', 'an', 'of', 'the', 'and', 'is', 'are', 'fact']:
                continue

            # Process words that start in uppercase as names
            elif word[0].isupper():
                if "'s" in word:
                    raise ValueError('Invalid input provided.')
                elif not found_predicate:
                    self._args_left.append(word.lower())
                else:
                    self._args_right.append(word.lower())

            # Everything else in the string is merged into the predicate
            # This makes it easier to catch errors in query phrasing
            else:
                # Singularize the predicate verb
                self._predicate.append(re.sub(
                    r'(ren|s)$', '', word.strip('.,?').lower()))
                found_predicate = True
        
        # Throw an error if predicate is still empty
        if not self._predicate:
            raise ValueError('Invalid input provided.')

    def _unwrap_args(self, args):
        """Unwraps a list of arguments into a single string."""

        count = len(args)
        if count == 0:
            # Return empty string if arguments are empty
            return ''
        elif count == 1:
            # Return the string itself if arguments list is a singleton
            return args[0]
        else:
            # Follow Prolog list syntax if multiple arguments
            return '[' + ', '.join(args) + ']'

    def get_prolog_query(self):
        """Returns the Prolog query representation of this object."""

        predicate = '_'.join(self._predicate)

        # Join the left and right args, ignoring empty strings
        args = ', '.join(filter(None, [
            self._unwrap_args(self._args_left),
            self._unwrap_args(self._args_right)
        ]))

        prolog_query = f'{predicate}({args})'

        return prolog_query

while True:
    query_string = input('> ')
    query_obj = None

    # Handle errors when parsing the input prompt
    try:
        query_obj = Query(query_string)
    except:
        print(f'{RED}Sorry, can you rephrase your prompt?\n{END}')
        continue # Skip to the next input

    prolog_query = query_obj.get_prolog_query()
    print(f'{CYAN}{prolog_query}{END}')

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
    
    print() # Newline