# select_into_Data_dref

This code shows how to propagate the local structure implicitely given by SELECT INTO DATA as a result to a method call.


## FROM THIS
```
METHOD selection.
 SELECT field1, field2 .... FROM dbtab1 INTO TABLE @DATA(itab1).
 SELECT field1, field2 .... FROM dbtab2 INTO TABLE @DATA(itab2).
ENDMETHOD
```

## TO THIS
```
METHOD selection.
 DATA(itab1) = select_data_1( ).
 DATA(itab2) = select_data_2( ).
 [...]
ENDMETHOD.
```

## BACKGROUND

SELECT INTO DATA is easy and comfortable, but if I want to modularize I need to define a structure type and a table type for every select. If I add a field to the select, I will have to adapt the structure type.

# Overhead

I wanted to avoid as much overhead as possible and keep the simplicity of SELECT INTO DATA. 
If I need to add or delete fields to/ from a selection statement, I can easily do that w/o any further adaptions.

# OTHER SOLUTIONS

## Solution with complete definition

In this solution I will have to change field changes in the structure as well as in the select (which I wanted to avoid).

```
TYPES: begin of _struc_1,
 field1 type ...,
 field2 type ...,
 end of _struc_1,
 _table_1 type standard table of _struc1 with default key.

METHODS select_data_1 RETURNING VALUE(result) TYPE _table_1.

METHOD select_data_1.
 SELECT field1, field2 ... INTO TABLE @result.
ENDMETHOD. 
```

## Solution CDS-View

A simple solution, that also requires only one change, is to define CDS-Views and use the CDS-view as returning type in the method.

Disadvantage: CDS-Views are new dictionary objects that make the class more complex because of more artefacts.
