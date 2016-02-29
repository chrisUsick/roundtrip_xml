# Premise
Create a DSL that makes creating Healthrules and transaction detections composable, simple, and declarative.

# Design
Using [ROXML](https://github.com/Empact/roxml) and the [Cleanroom Pattern](https://sethvargo.com/the-cleanroom-pattern/) a DSL could be easily created that is easy to maintain, secure, and meets the requirements.   

For each non-leaf element in the config schema (healthrules or transaction detections) there is a ROXML class. These classes expose 2 methods: `define` and `create`. `define` is used to define a subclass of that element. `create` is used to create instances of that element which correspond to the actual XML configuration.

# Example
## XML
```XML
<custom-match-point>
    <name>API Calls</name>
    <business-transaction-name>API Calls</business-transaction-name>
    <entry-point>PHP_WEB</entry-point>
    <background>false</background>
    <enabled>true</enabled>
    <match-rule>
        <normal-rule>
            <enabled>true</enabled>
            <priority>10</priority>
            <uri filter-type="STARTSWITH" filter-value="/api/"/>
            <properties/>
        </normal-rule>
    </match-rule>
</custom-match-point>
```
The DSL will have classes named `CustomMatchPoint`, `MatchRule`, and `NormalRule`.  

## DSL Definitions
Suppose you want to define a subclass of a custom match point that exposes only the name, uri filter type and filter value.
```ruby
CustomMatchPoint.define :NormalMatchPoint do |rule_name, uri_value, uri_type|
  name rule_name
  match_rule NormalRule.create do
    enabled true
    priority 1
    uri (create :Uri do
      filter_type uri_type
      filter_value uri_value
    end)
  end
end
```
`define` accepts a symbol for the subclass's name and a block. The block accepts the parameters that will be passed through the `create` method (see below). The above code creates a class called `NormalMatchPoint`. Notice that the DSL exposes a method for each `xml_accessor` of the parent class. Note: `xml_accessor` is a method of ROXML to create the mapping from XML to an object.   

Also shown in this example is use of the `create` method. Here, the `uri` property of the custom match point is set to a uri instance, and it's values are set to the passed in parameters.

# utilizing the Definitions
Now, create Normal match rules is each. Simply call the create method and pass the desired methods.
```ruby
NormalMatchPoint.create 'API Calls', '/api/', 'STARTSWITH'
NormalMatchPoint.create 'Browse diffusion', '/diffusion/', 'STARTSWITH'
```
You could even subclass `NormalMatchPoint` if you wanted!
```ruby
NormalMatchPoint.define :StartsWithNormalMatchPoint do |rule_name, uri|
  parent rule_name, uri, 'STARTSWITH'
end
```

Ideally, definitions could be spread across multiple files like a regular ruby library.
