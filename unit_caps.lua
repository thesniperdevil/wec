--[[

Dynamic unit caps and restrictions for players.

OBJECTS:

RecruiterCharacter: RECRUITER_CHARACTER: stores all information about a given character.
----------------------------------------------------
Fields: 
    "CQI": CA_CQI: Stores the CQI of the character
    "QueueTable": vector<unit_component_ID: string>: Stores the queue of the character.
    "CurrentRestrictions": map<unit_component_ID: string, boolean>: Stores the units that should be recruitable.
    "QueueEmpty": boolean: stores whether the QueueTable has anything in it.
    "QueueCount": map<unit_component_ID, number>: stores the quantity of each unit in the Queue.
    "CurrentArmy": vector<string>: Stores the army of the character. Refreshed whenever the character is selected.
    "ArmyCount":  map<unit_component_ID, number>: stores the quantity of each unit in the Army.
    "TotalCount": map<unit_component_ID, number>: stores the quantity of each unit in the Army + QUEUE.
    "RegionKey": string : Stores the key of the current region of the character. Refreshed whenever the character is selected.
----------------------------------------------------
Methods:
    "create": private: (cqi: CA_CQI): creates a blank character object.
    "load": private: (cqi: CA_CQI, vector<unit_component_ID: string>): creates a character object with a provided queuetable.
    "save": private: () --> cqi, vector<unit_component_ID: string> : returns the cqi and queuetable for saving.
    "AddToQueue": private: (unit_component_ID: string): adds a unit to the queue.
    "RemoveFromQueue": private: (QueuedLandUnitComponentID: string): calculates the queue position for the component and removes the relevant unit.
    "EvaluateArmy": private: (): refreshes the army list to reflect the gamestate.
    "SetCounts" : private: (): counts the queue table, army list, and total counts.
    "GetCounts" : private: () --> map<unit_component_ID, number>: gets the TotalCount field
    "EmptyQueue": private: (): sets the QueueEmpty boolean to true, and empties the QueueTable.
    "IsQueueEmpty": private: () --> boolean : returns the QueueEmpty Boolean.
    "SetRegion" : private: (): sets the RegionKey field
    "GetRegion" : private: () --> string: gets the RegionKey field
    "GetTotalCount": private () --> map<string, number>: returns the TotalCount field
    "GetTotalCountForUnit": private(unit_component_ID: string) --> number: returns the TotalCount for a specific unit.
    "GetRegionKey": private () --> string: returns the RegionKey field.
    "SetManager": private: (manager: RECRUITER_MANAGER): gives the object access to its manager.
    "SetRestriction" : private : (unit_component_ID: string, restrict: boolean) : Sets the restriction for that unit to the boolean value.
    "ApplyRestrictionToUnit": private : (unit_component_ID: string) : Applies the restrictions to the UI.
  
----------------------------------------------------

RecruitmentManager: RECRUITER_MANAGER: stores all characters and all information about restrictions.
----------------------------------------------------
Fields:
    "Characters": map<CA_CQI, RECRUITER_CHARACTER>: stores the recruiter character objects at a given CQI.
    "CurrentlySelectedCharacter": RECRUITER_CHARACTER : stores the currently selected character object.
    "Region Restrictions": map<REGION_KEY: string, map<unit_UI_ID, boolean>
    "Unit Quantity Restrictions": map<unit_UI_ID, number> : stores the quantity of each unit allowed in each army.
----------------------------------------------------
Methods:
    "AddRegionRestriction": public: (unit_key: string, region: string) : sets a region restriction for a unit key.
    "RemoveRegionRestriction": public: (unit_key: string, region: string) : sets a region restriction for a unit key.
    "GetIsRegionRestricted":  public: (unit_key: string, region: string) --> boolean : Returns whether the passed unit is restricted in the passed region.
    "SetUnitQuantityRestriction": public: (unit_key: string, count: number) : sets a unit quantity restriction for a unit key.
    "RemoveUnitQuantityRestriction" : public: (unit_key: string) : removes the UnitQuantityRestriction for the passed unit.
    "GetUnitQuantityRestriction" : public: (unit_key: string) --> : returns number of units allowed.
    "SetCurrentlySelectedCharacter": private: (cqi: CA_CQI) : sets the CurrentlySelectedCharacter field.
    "EvaluateAllRestrictions": private: () : 
        Loops through the present unit cards; for each:
            Calls GetRegion(), uses it to call GetIsRegionRestricted()
            Calls GetTotalCountForUnit(), compares it to the result of GetUnitQuantityRestriction()
            Passes both the previous two conditions to SetRestriction()
            Calls ApplyRestrictionToUnit()
        Repeats
    ----------------------------------------------------
    "EvaluateSingleUnitRestriction" : private: (unit_component_ID: string) :
        Calls GetRegion(), uses it to call GetIsRegionRestricted()
        Calls GetTotalCountForUnit(), compares it to the result of GetUnitQuantityRestriction()
        Passes both the previous two conditions to SetRestriction()
        Calls ApplyRestrictionToUnit()
    ----------------------------------------------------
    "OnCharacterSelected": private: (context: CA_CONTEXT): 
        If a RECRUITER_CHARACTER does not exist for the character context CQI, calls create()
            Calls EvaluateArmy()
            Calls SetCounts()
            Calls SetRegion()
            Calls EvaluateAllRestrictions()
    ----------------------------------------------------
    "OnCharacterFinishedMoving": private: (context: CA_CONTEXT)
        If a RECRUITER_CHARACTER does not exist for the character context, calls create()
            If IsQueueEmpty returns false, calls EmptyQueue()
    ----------------------------------------------------
    
         
----------------------------------------------------
EVENT BASED SCRIPTING
----------------------------------------------------
On Character Selected: 
    IF Model finds relevant character object >>>>
        Update Current Army List.
        Update Army Location.
        Updates Army Count.
        Updates Total Count. 
        Update Current restrictions.
        Sets this character object to the currently selected position in the model.
    ELSEIF find fails, create a new character object for that character.
----------------------------------------------------
On CampaignPanelOpened:
    Decide if the panel is the recruitment panel.
        If yes, apply the stored current restrictions ot the recruitment UI.
----------------------------------------------------
On ComponentLClickDown
    Decide if the option is a recruitment choice.
        If yes, then lock the clicked component and send the new information to the model.
        Update the Stored queue with the new unit.
        Update the Queue Counts.
        Update the Total Counts.
        Update Current Restrictions.
        Unlock unit card UI.
----------------------------------------------------
On ComponentLClickDown
    Decide if the Option is a Queued Unit.
        If yes, remove that unit from the queue.
        Recalculate the Queue Count.
        Recalculate the Total Count.
        Re-evaluate the current restrictions.
----------------------------------------------------
On Unit Recruited:
    Decide if the Unit belongs to a human
        If yes, remove that unit from the Queue table for the given character. 
----------------------------------------------------
On GameSaved
    For each Character Object currently stored in the model, save the queueTable.
----------------------------------------------------
On GameLoaded
    For each saved QueueTable, create a new character object with the queuetable.
----------------------------------------------------
On CharacterMoved
    Check if the character is human
        If yes, decide whether there is anything in the QueueTable for that Character.
            If yes, destroy the queue table and set the QueueEmpty boolean. 
----------------------------------------------------

]]