#!/usr/bin/env python
from xml.parsers import expat

generative = []

elem_stack = []

def start_element(name, attributes):
	if name == 'var' and elem_stack[-1] == 'command':
		generative[-1] += attributes['key'].upper()
	elif name == 'command':
		generative.append('')
	elem_stack.append(name)

def end_element(name):
	elem_stack.pop()

def char_data(data):
	if elem_stack[-1] == 'command':
		generative[-1] += data
	

parser = expat.ParserCreate()
parser.StartElementHandler = start_element
parser.EndElementHandler = end_element
parser.CharacterDataHandler = char_data

with open('zine.xml', 'rb') as f:
	parser.ParseFile(f)

print(generative)
