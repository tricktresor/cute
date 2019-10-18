# cute
Custom Table Editor - Alternative to SM30

![cute Logo](/img/really-cute-logo.png)

# abstract

Table maintenance in SAP systems is mainly done via generated table maintenance views and transaction SM30. These generated maintenance views have some annoying limitations. The project *CUTE - CUstom Table Editor* wants to offer an alternative to this.

https://blogs.sap.com/2019/10/15/replacing-the-good-old-maintenance-view-generator/

# planned features

* simple use without any generations needed
  * customizing entry or kind of marker interface that a table can be used for editing
  * Authorizations settings
  * automatic check for foreign key definitions
  * automatic search help for table or data element
  * automatic descriptive text for fields if check table or domain values exist
* custom checks and data manipulation with table specific code
* locking for key values not the complete table
* visualizing edited, deleted and inserted lines/ values
* transportation function for changed lines (customizing)
* display of all input errors at once without limiting the correction to the one false entry
* as in SM30 maintain also the description of the assigned text table.
  * this gives the chance to maintain different languages at once (each language in a different column). 
* ...

# technique

An ALV-grid seems to be the best tool for most common SAP systems. Dynamic creation for internal tables plus editable ALV-grid already provides the main features for editing. 

# known challenges

* the grid control only loads the lines into the frontend which are displayed on the screen. With many table lines there might be some issues that only the displayed entries are copied/ changed
* changing / copying key values might be some work...
* there are some issues with wrong F4 value help in a grid when using generated internal tables
* SM30 automatically generated the maintenance of the assigned text table. Might be okay for a simple table but eventually complex for views. 

