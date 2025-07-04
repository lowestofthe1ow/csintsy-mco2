from pyswip import Prolog, Functor, call
import re

Prolog.consult('knowledge_base.pl')

CYAN = "\033[0;36m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
END = "\033[0m"

class Query:
    def __init__(self, query_string):
        """Creates a new Query instance given a natural-language prompt.""" 

        # Private attributes ===================================================
        self._args_left = []   # Arguments before the predicate
        self._args_right = []  # Arguments after the predicate
        self._predicate = []   # Predicate name
        #=======================================================================

        # Public attributes ====================================================
        self.marker = ''       # Question marker ('are', 'is', 'who')
        self.assertion = False # Whether the query is an assertion of a fact
        #=======================================================================

        # Split the prompt into words, stripping them of certain characters
        words = [word.strip('.,?') for word in query_string.split()]

        # The first word is the question marker
        self.marker = words.pop(0).lower()

        # Questions that start with 'who' are open-ended
        if self.marker == 'who':
            # 'X' is a placeholder for use in Prolog
            self._args_left.append('X')

        # If the query starts with 'is' or 'are', then it is closed-ended.
        # Otherwise, it is an assertion of a fact.
        elif self.marker not in ['is', 'are']:
            self.assertion = True
            self._args_left.append(self.marker)
            self._predicate.append('fact') # Add "fact_" tag to assertions

        # Tracks whether we've encountered the predicate
        found_predicate = False 

        # Process the query word for word
        for word in words:
            # Ignore these words
            if word in ['a', 'an', 'of', 'the', 'and', 'is', 'are']:
                continue

            # Process words that start in uppercase as names
            elif word[0].isupper():
                if "'s" in word:
                    raise ValueError("Invalid input provided.")
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
            raise ValueError("Invalid input provided.")

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

        prolog_query = '{predicate}({args})'.format(
            predicate = '_'.join(self._predicate),
            # Join the left and right args, ignoring empty strings
            args = ', '.join(filter(None, [
                self._unwrap_args(self._args_left),
                self._unwrap_args(self._args_right)
            ]))
        )

        return prolog_query

while True:
    query_string = input("> ")
    query_obj = None

    # Handle errors when parsing the input prompt
    try:
        query_obj = Query(query_string)
    except:
        print(RED + "Sorry, can you rephrase your prompt?\n" + END)
        continue

    prolog_query = query_obj.get_prolog_query()
    print("\n" + CYAN + prolog_query + END)

    # Handle assertions
    if query_obj.assertion:
        try:
            # Prolog.query() returns a generator that we iterate with next()
            # This will raise a StopIteration exception if safe_assertz() fails
            next(Prolog.query(
                # Wrap query in a call to safe_assertz()
                'safe_assertz({query}).'.format(query = prolog_query)))
            print(GREEN + 'OK! I learned something.' + END)
        except Exception as e:
            if "contradiction" in str(e):
                # Contradiction error
                print(RED + "That's impossible!" + END)
            else:
                # Unknown predicate error
                print(RED + "Sorry, can you rephrase your prompt?" + END)

    # Handle open-ended questions
    elif query_obj.marker == 'who':
        try:
            result = ', '.join(
                set([entry.get('X').capitalize() 
                    for entry in list(Prolog.query(prolog_query))])
            )
            if result:
                print(GREEN + result + END)
            else:
                print(RED + "Couldn't find anyone." + END)
        except:
            print(RED + "Sorry, can you rephrase your prompt?" + END)

    # Handle Boolean queries
    else:
        try:
            if list(Prolog.query(
                    # Wrap query in a call to safe_assertz()
                    'once({query}).'.format(query = prolog_query))):
                print(GREEN + "Yes!" + END)
            else:
                print(RED + "No." + END)
        except:
            print(RED + "Sorry, can you rephrase your prompt?" + END)
    
    print() # Newline