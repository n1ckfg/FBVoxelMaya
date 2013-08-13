from maya.cmds import *
from pymel.core import *

def createShader(shaderType,shaderColor,useTexture):
	target = ls(sl=True)
	shader=shadingNode(shaderType,asShader=True)
	if(useTexture==True):
		file_node=shadingNode("file",asTexture=True)
	shading_group= sets(renderable=True,noSurfaceShader=True,empty=True)
	try:
		setColor(shader,shaderColor)
	except:
		setColor(shader,(0.5,0.5,0.5))
	connectAttr('%s.outColor' %shader ,'%s.surfaceShader' %shading_group)
	if(useTexture==True):
		connectAttr('%s.outColor' %file_node, '%s.color' %shader)
	select(target)
	return shader

def assignShader(shader):
	hyperShade(a=shader)

def quickShader(shaderType,shaderColor,useTexture):
	shader = createShader(shaderType,shaderColor,useTexture)
	assignShader(shader)

def setColor(s,c):
	cc = (float(c[0]) / 255.0, float(c[1]) / 255.0, float(c[2]) / 255.0)
	t = abs(1-(float(c[3]) / 255.0))
	ct = (t,t,t)
	setAttr(s + ".color", cc)
	if(len(c)>3):
		setAttr(s + ".transparency", ct)
