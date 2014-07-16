# Filename: simpleConvertXML.js  
# Timestamp: 2013.05.13-01:58:53 (last modified)  
# Author(s): Bumblehead (www.bumblehead.com)  
simpleConvertXML = (->
  
  # ELEMENT_NODE                :  1,
  # ATTRIBUTE_NODE              :  2,
  # TEXT_NODE                   :  3,
  # CDATA_SECTION_NODE          :  4,
  # ENTITY_REFERENCE_NODE       :  5,
  # ENTITY_NODE                 :  6,
  # PROCESSING_INSTRUCTION_NODE :  7,
  # COMMENT_NODE                :  8,
  # DOCUMENT_NODE               :  9,
  # DOCUMENT_TYPE_NODE          : 10,
  # DOCUMENT_FRAGMENT_NODE      : 11,
  # NOTATION_NODE               : 12
  isArray = (obj) ->
    return typeof obj.length is "number"  unless obj.propertyIsEnumerable("length")  if typeof obj is "object" and obj
    false
  isArray: isArray
  
  # input:                               output:
  #  data = {                             <data>
  #    price : "$15.87",                    <price>$15.87</price>
  #    happy : {                            <happy>
  #      say      : "i'm happy",              <say>i'm happy</say>
  #      respond  : "you're happy",           <respond>you're happy</respond>
  #      conclude : "we're all happy"         <conclude>we're all happy</conclude>
  #    },                                   </happy>
  #    isfinal : "true"                     <isFinal>true</isFinal>
  #  }                                    </data>
  #
  getObjAsXMLstr: (data) ->
    getAsNodeLeaf = (name, content) ->
      nodeLeafStr.replace(/:name/g, name).replace /:v/, getNodeTree(content)
    getAsNodeParent = (name, content) ->
      nodeParentStr.replace(/:name/g, name).replace /:v/, getNodeTree(content)
    getNode = (name, content) ->
      if isArray(content)
        content.map((p) ->
          getNode name, p
        ).join ""
      else if typeof content is "object"
        getAsNodeParent name, content
      else getAsNodeLeaf name, content  if typeof content is "string"
    getNodeTree = (obj) ->
      xmlStr = ""
      if obj and typeof obj is "object"
        for name of obj
          xmlStr += getNode(name, obj[name])
      else xmlStr += obj.toString()  if typeof obj is "string"
      xmlStr
    xmlStr = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    nodeParentStr = "<:name>\n:v</:name>\n"
    nodeLeafStr = "<:name>:v</:name>\n"
    xmlStr += getNodeTree(data)
    xmlStr

  
  # note: appending `Arr` to a node name forces the value to be recognized as 
  #       an array. using the criteria of counting node name instances, creates
  #       inconsistent opportunities for data to be qualified as array or
  #       string.
  #
  # input:                              output:
  #  <data>                               data = {
  #    <price>$15.87</price>                price : "$15.87",
  #    <happy>                              happy : {
  #      <say>happy?</say>                    say : "happy?",
  #      <respond>happy!</respond>            respond : "happy!",
  #      <conclude>HAPPY</conclude>           conclude : "HAPPY"
  #    </happy>                             },
  #    <isFinal>true</isFinal>              isFinal : "true",
  #    <name>dave</name>                    name : ["chris",
  #    <name>chris</name>                           "dave"],
  #    <fooArr>value</fooArr>               fooArr : ["value"]
  #  </data>                              }
  #
  getXMLAsObj: (xmlObj) ->
    getNodeAsArr = (nodeChild) ->
      nodeObj = getXMLAsObj(nodeChild)
      nodeName = nodeChild.nodeName
      finObj = undefined
      
      # property names are unknown here, 
      # and so for-loop is used
      for o of nodeObj
        if nodeObj.hasOwnProperty(o)
          if isArray(nodeObj[o])
            finObj = nodeObj[o]
          else
            finObj = [nodeObj[o]]
      finObj
    
    # get a node's value redefined to accomodate
    # attributes
    getWithAttributes = (val, node) ->
      attrArr = node.attributes
      attr = undefined
      x = undefined
      newObj = undefined
      if attrArr
        if isArray(val)
          newObj = val
        else if typeof val is "object"
          newObj = val
          x = attrArr.length
          while x--
            val[attrArr[x].name] = attrArr[x].nodeValue
        else if typeof val is "string"
          if attrArr.length
            newObj = {}
            x = attrArr.length
            while x--
              if val
                newObj[attrArr[x].nodeValue] = val
              else
                newObj[attrArr[x].name] = attrArr[x].nodeValue
        else
          newObj = val
      newObj or val
    getXMLAsObj = (node) ->
      nodeName = undefined
      nodeType = undefined
      strObj = ""
      finObj = {}
      isStr = true
      x = undefined
      attr = undefined
      attrArr = undefined
      if node
        if node.hasChildNodes()
          node = node.firstChild
          loop
            nodeType = node.nodeType
            nodeName = node.nodeName
            if nodeType is 1
              isStr = false
              
              # if array trigger, make this an array
              if nodeName.match(/Arr\b/)
                finObj[nodeName] = getNodeAsArr(node)
              else if finObj[nodeName]
                
                # if array already formed, push item to array
                # else a repeated node, redefine this as an array
                if isArray(finObj[nodeName])
                  
                  # if attribute... define on first attribute
                  finObj[nodeName].push getWithAttributes(getXMLAsObj(node), node)
                else
                  finObj[nodeName] = [finObj[nodeName]]
                  finObj[nodeName].push getWithAttributes(getXMLAsObj(node), node)
              else
                finObj[nodeName] = getWithAttributes(getXMLAsObj(node), node)
            else strObj += node.nodeValue  if nodeType is 3
            break unless (node = node.nextSibling)
        (if isStr then strObj else finObj)
    isArray = @isArray
    getXMLAsObj xmlObj
)()