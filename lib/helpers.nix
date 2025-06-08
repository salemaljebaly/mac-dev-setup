{ lib }:

{
  # Helper function to create modular configurations
  mkIfElse = p: yes: no: if p then yes else no;
  
  # Function to merge lists conditionally
  concatIf = condition: list: if condition then list else [];
}