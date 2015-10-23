#!/usr/bin/env python
from xml.parsers import expat
import subprocess, datetime

# calculate paper/page sizes
paperHeightIn = 11
paperWidthIn = 8.5
verticalHalfFolds = 2
verticalThirdFolds = 0
horizontalHalfFolds = 0
horizontalThirdFolds = 1
numHalfFolds = verticalHalfFolds + horizontalHalfFolds
numThirdFolds = verticalThirdFolds + horizontalThirdFolds
numRows = pow(2, verticalHalfFolds) * pow(3, verticalThirdFolds)
numColumns = pow(2, horizontalHalfFolds) * pow(3, horizontalThirdFolds)
numPages = 2 * numRows * numColumns
dpi = 300
pageWidthPx = (paperWidthIn / numColumns) * dpi
pageHeightPx = (paperHeightIn / numRows) * dpi
topMarginIn = .5
bottomMarginIn = .5
outsideMarginIn = .5
insideMarginIn = .75
contentWidthPx = pageWidthPx - ((insideMarginIn + outsideMarginIn) * dpi)
contentHeightPx = pageHeightPx - ((topMarginIn + bottomMarginIn) * dpi)

class xmlData:
	
	def __init__(self):
		self.doc = []
		self.elemStack = []
		pass
	
	def startElement(self, name, attributes):
		elem = {'type':'elem', 'name':name, 'attributes':attributes, 'children':[]}
		if len(self.elemStack) == 0:
			# root
			self.doc.append(elem)
			self.root = elem
		else:
			self.elemStack[-1]['children'].append(elem)
			if name in self.elemStack[-1]:
				self.elemStack[-1][name].append(elem)
			else:
				self.elemStack[-1][name] = [elem]
		self.elemStack.append(elem)
		print(len(self.elemStack))
	
	def endElement(self, name):
		self.elemStack.pop()

	def characters(self, data):
		text = {'type':'text', 'value':data}
		self.elemStack[-1]['children'].append(text)
		print(data)

	def parse(self, filename):
		parser = expat.ParserCreate()
		parser.StartElementHandler = self.startElement
		parser.EndElementHandler = self.endElement
		parser.CharacterDataHandler = self.characters
		with open(filename, 'rb') as f:
			parser.ParseFile(f)

# process the zine xml
zine = xmlData()
zine.parse('zine.xml')

# loop through pages
print(zine.root['name'])
print(len(zine.root['children']))
print(len(zine.root['generative']))

# construct initial variable map
replaceables = {};
replaceables['width_in'] = contentWidthPx / dpi;
replaceables['height_in'] = contentHeightPx / dpi;
replaceables['width_px'] = contentWidthPx;
replaceables['height_px'] = contentHeightPx;
now = datetime.datetime.now();
replaceables['timestamp'] = now.timestamp();
replaceables['year'] = now.year;
replaceables['month'] = now.month;
replaceables['day'] = now.day;
replaceables['hour'] = now.hour;
replaceables['minute'] = now.minute;
replaceables['second'] = now.second;
replaceables['microsecond'] = now.microsecond;

def varReplace(elem, replaceables):
	pass
	#TODO

