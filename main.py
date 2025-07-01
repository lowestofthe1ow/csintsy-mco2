from pyswip import Prolog
import re

Prolog.consult('knowledge_base.pl')

class Query:
    def __init__(self, query_string):
        self._arguments = []
        self._predicate = ''
        self.marker = ''
        self.assertion = False

        words = query_string.split()
        self.marker = words.pop(0).strip(',?').lower()

        if self.marker == 'who':
            self._arguments.append('X')
        # If the query did not start with these, then treat it as an assertion.
        elif self.marker not in ['is', 'are', 'do']:
            self.assertion = True
            self._arguments.append(self.marker)
            # Asserted predicates (declared facts) must start with 'fact_'
            self._predicate += 'fact_'

        # Process the query
        for word in words:
            # Ignore these words
            if word in ['a', 'an', 'of', 'the', 'and', 'is', 'are']:
                continue
            # Process words that start in uppercase as names
            elif word[0].isupper():
                self._arguments.append(
                    word.strip('.,?').lower().replace("'s", ''))
            # Everything else in the string is merged into the predicate
            # This makes it easier to catch errors in query phrasing
            else:
                self._predicate += re.sub(
                    r'(ren|s)$', '', word.strip('.,?').lower())
    
    def get_prolog_query(self):
        prolog_query = '{predicate}({arguments})'.format(
            predicate = self._predicate, 
            arguments = ', '.join(self._arguments)
        )

        return prolog_query

while True:
    query_string = input("Prompt: ")
    query_obj = Query(query_string)
    
    prolog_query = query_obj.get_prolog_query()
    #print(prolog_query)

    if query_obj.assertion:
        Prolog.assertz(prolog_query)
        print("OK! I learned something.")
    elif not query_obj.marker == 'who':
        # Boolean queries
        if len(list(Prolog.query(prolog_query))) > 0:
            print("Yes!")
        else:
            print("No.")

        