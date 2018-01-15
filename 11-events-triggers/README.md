This lab is designed to teach you how to write Data Manipulation Language (DML) triggers with Oracle’s PL/SQL. You create a logger table where you record changes to the rows in the item table. Those changes occur when you call an INSERT, UPDATE, or DELETE statement. You create two DML triggers and a manage_item package to accomplish this task, which lets you leverage overloading. Overloading lets you write procedures that logs new and old row information from an INSERT or UPDATE statements. Overloading also lets you write a procedure that logs old row information when you delete a row from the item table.
<ul>
  <li>Learn how to create a event logging table.</li>
  <li>Learn how to create insert, update, and delete DML triggers.</li>
  <li>Learn how to leverage overloading in a package.</li>
  <li>Learn how to test insert, update, and delete DML triggers.</li>
</ul>
