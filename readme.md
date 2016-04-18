# Appdynamics DSL for Healthrules and Transaction Detections
This repository contains the core library for parsing a ruby-based DSL which will be used to write Appdynamics configurations in.

## Background
Healthrules and Transaction detections (a.k.a business transactions) can be imported and exported from Appdynamics using XML. This XML is not easy to write and there is often a lot of duplication. The DSL provides a means to write reusable pieces of code so that the duplication could be minimized. Since there are hundreds of types of elements that may be in a given healthrules or transaction detections file writing these configurations was going to be difficult. To solve this problem the DSL interpreter will parse existing configuration XML files to understand the valid elements. When interpreting the DSL, only the properties that existed in the XML can be used in the DSL; This provides a level of type safety.

## TL;DR
See [this](spec/integration/e2e_healthrules_definitions_spec.rb) unit test.  It demonstrates the entire DSL. 

## Language
The DSL is ruby based and is interpreted in the ruby interpreter, so an ruby expression is valid.   
The following examples will be based on Healthrules XML. Since the DSL is generated from the corresponding XML one must understand the XML first. A basic healthrules document looks like this:  
```xml
<health-rules controller-version="004-001-008-007">  
  <health-rule>  
    <name>Business Transaction response time is much higher than normal</name>  
    <type>BUSINESS_TRANSACTION</type>  
    ...  
  </health-rule>  
  <health-rule>  
    ...  
  </health-rule>  
  ...  
</health-rules>  
```  
### Classes
Each element that doesn't contain a text value or have attributes is has a dynamically generated class for it. In the above example there would be classes named `:HealthRules` and `:HealthRule`. Notice that a class name is the element's name capitalized and hyphens removed. The class names are shown as ruby symbols because this is how they will be referred to in the DSL.  
Each class has a method for each child element and each attribute it has. For example: The `:HealthRules` class has a method called `controllerVersion` and `healthRule`. Methods are named the same as classes except their first letter is lowercase. Calling these methods will set the value of the corresponding XML property. The DSL knows if a property should contain multiple values, or just 1. The `controllerVersion` method can only be called once per `:HealthRules` element, whereas the `healthRule` method can be called multiple times because `<health-rules>` element contains many individual `<health-rule>` elements. 

### DSL Root file
A root DSL file is executed in the context of a root element (either `<health-rules>` or `<transaction-detections>`). This means that in the root file you can simply start calling the root classes methods. E.g.  
```ruby  
controllerVersion '004-001-008-007'  
healthRule do   
  name 'Business Transaction response time is much higher than normal'  
  type 'BUSINESS_TRANSACTION'  
end   

healthRule do   
  # ...  
end  
```    
### Defining classes
Classes can be defined in the DSL itself. This allows you to create reusable pieces of code. The rest of this section will refer to these files:  

 - [healthrule-helpers](spec/fixtures/healthrule-helpers.rb)
 - [healtrules-dsl](spec/fixtures/healthrules-dsl.rb)
 
Definitions can only be created at the top level, not inside a child element. They can be wrote in the root file or in an external file that is included in the root file.  
The syntax is:  
```ruby  
define :NewClassName, :ParentClass, :param_1, :param_2, ..., :param_n do   
  ...  
end  
```  
The first 2 parameters are required: the class name and the parent class. Following those arguments there can be zero or more parameters which behave like added properties to the newly created class. The new class inherits all the properties of the parent class.  
To use a user-defined class, simply pass it in as a parameter to a method, for example:   
```ruby
property :UserDefinedClass do   
end  
```  
Since user-defined classes inherit from their parent class, any parent method can be called when using it. Here is a full example taken from the above files.    
```ruby  
define :PolicyCondition2, :PolicyCondition do  
  type 'boolean'  
  operator 'AND'  
end  
```   
`:PolicyCondition2` extends `:PolicyCondition` and has no added parameters. This class simply calls the `type` and `operator` methods of `:PolicyCondition`. This class is used a convenience class so that the `type` and `operator` methods don't have to be set on each policy condition.   
```ruby   
policyCondition :PolicyCondition2 do  
  condition1 do  
    type 'leaf'   
    ...  
  end  
  ...  
end  
```  
Notice that `condition1` is a method of `:PolicyCondition` not `:PolicyCondition2`.  
## Library
The basic process of interpreting some DSL file is as follows:   

 1. a `DslRuntime` instance is created  
 2. the creates a classes based on XML input (`DslRuntime#populate`)  
   2.1 RoxmlBuilder class recursively reads an XML document and generates the classes, adding them to the runtimes class list  
 3. The DSL gets parsed (see `DslRuntime#evaluate`)   
   3.1 `RootCleanroom` class is used to interpret the top level DSL. `BaseCleanroom`'s are recursively created to parse each element  
 4. The final output is a ROXML class which can be turned directly into XML.   
 
Read the class documentation to get more detailed descriptions of the classes.  


# Auto-refactoring functionality 
This is a prototype feature. 

## process 

 1. ROXML class to a hash format
 2. calculate the differences of all elements
 3. extract similarities 
 4. write sub-classes
 5. re-write DSL to utilize sub classes.
 
The main task takes in a group of DSL files to refactor. It will write the sub-classes to a file in the same directory, and modify the DSL files.
