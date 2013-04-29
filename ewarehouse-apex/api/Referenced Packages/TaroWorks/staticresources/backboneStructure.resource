/*
 * (c) Copyright 2013 Grameen Foundation USA. All rights reserved
 */

//-------------------Models structure ------------------------

/**
*   Model that represents a combo (Question mapping), the question model has an array of ComboItem.
*/
var ComboItem = Backbone.Model.extend({
    initialize: function(fieldArray){
        this.set({'fieldList' : fieldArray});
    },
});

var AbstractQuestion = Backbone.Model.extend({

});

/**
*   This model represents a question, it has common methods that are the same in all type of questions.
*/
var Question = AbstractQuestion.extend({

    initialize: function(){
        this.set({childrenMappedFields: new Array()});
        this.set(NUMBER_HEADER_ATTR, '');
    },

    /**
    *    Populates the children combo of the question (related through @param1 to the header combo) with the fields of the object value of the
    *    selected header combo.
    *    At the end rerenders the question view (will be fixed to be rerender automatically).
    *    @param classSelected Relation with header combo.
    *    @param fieldList List of fields of the new object, format: {obj.type : '', obj.name : '', obj.label: '' }.
    *    @param objectName Name of the related salesforce object.
    *    @param questionMappedList List of mapped questions (in case it was a DB retrieved column).
    *    @param listFieldSelected Name of the selected id field.
    */
    setFieldsToCombo : function(classSelected, fieldList, objectName, questionMappedList, listFieldSelected){
        var self             = this;
        var comboRelated     = _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == classSelected; });
        var comboData        = [];
        var dummyUsedFields  = {};
        comboData.push({value: UNDEFINED_VALUE, label: UNDEFINED_LABEL, selected: true});
        // if it was retrieved from the DB, we save an array with the question mapped of the current question, and selected survey.
        if(questionMappedList) var childrenSavedOfSurvey = _.filter(questionMappedList, function(childMF){ return childMF.relatedHeaderCombo == classSelected && childMF.questionId == self.get('Id')});

        _.each(fieldList, function(field){
            // Iterate over list of fields, displaying only the ones that are filtered.
            var isFieldInArray = _.contains(self.get('mapAllowedFields'), field.type);
            if(isFieldInArray){
                var isSelected =  (childrenSavedOfSurvey) ? typeof _.find(childrenSavedOfSurvey, function(childMF){ return childMF.mappedFieldName == field.name }) != 'undefined' :  false;
                if(isSelected) {
                    _.each(comboData, function(field){ if(field.selected == true) field.selected = false; });
                    var isListFieldSelected = (listFieldSelected == field.name);
                    self.setOptionToComboField(field.name, field.label, classSelected, isListFieldSelected);

                    // Adds the selected fields to the list of used fields.
                    fMPage.addFormatUsedField(dummyUsedFields, classSelected, self.get(ID_ATTRIBUTE), field.name);
                }
                comboData.push({value: field.name, label: field.label, selected: isSelected, required: field.required});
            }
        });
        fMPage.addUsedFields(dummyUsedFields);                      // Add field to the list of used fields.
        var idCombo = $(".idFieldClass[name='"+classSelected+"']"); // Assigning to the Id combo with the values (Id, name and if a unique or external id is selected)
        idCombo.empty();
        idCombo[0].options[0] = new Option(UNDEFINED_LABEL,UNDEFINED_VALUE);
        var selectedOptionArray = globalSelectedOptions.getSelectedOptionArray(classSelected).sort();
        var optionList = idCombo[0].options;
        for (var i = 0 ; i < selectedOptionArray.length; i++){
            if(selectedOptionArray[i][0] != UNDEFINED_VALUE) optionList[optionList.length] = new Option(selectedOptionArray[i][1],selectedOptionArray[i][0]);
        }

        $(idCombo).val(listFieldSelected);

        comboData.sort(this.customSortByName);
        comboRelated.set('sfobjectRelated', objectName);
        comboRelated.set(FIELD_LIST_ATTR, comboData);
        this.trigger("change:childrenMappedFields");
    },

    /**
    *    Returns the combo related with the Id of the mapping object
    *     @param name Id of the survey mapping.
    */
    getComboRelated :function(name){
        return _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == name; });
    },

    /**
    *    Adds the option passed as argument to the headerRelated IdList select combo. (Used when retrieving the values from database)
    */
    setOptionToComboField : function(optionName, optionLabel, headerRelated, isFieldSelected){
        var selectedOptionArray = globalSelectedOptions.getSelectedOptionArray(headerRelated).sort();
        var comboElement        = $(".idFieldClass[name='" + headerRelated + "']");
        globalSelectedOptions.setValue( headerRelated,this.get('Id'),optionName, optionLabel);

    },

    /**
    *    Creates a new column (field mapping) to the question.
    *    @param nameToRelate Number of the recently created header combo (this way we relate the combo of the question with the combo
    *    of the header).
    */
    createEmptyColumn : function(nameToRelate){
        var oldComboList    = this.get(CHILDREN_ATTR);
        var comboData       = [];
        comboData.push({value: UNDEFINED_VALUE, label: UNDEFINED_LABEL, selected: true});
        var newComboItem    = new ComboItem(comboData);
        newComboItem.set(RELATED_COMBO_ATTR, nameToRelate);
        oldComboList.push(newComboItem);
        this.set(CHILDREN_ATTR, oldComboList);
        this.trigger("change:childrenMappedFields");
    },

    /**
    *    Set the "selected" attribute of the selected field, true.
    *    Also sets the question as already modified.
    *    @param nameFieldSelected Name of the selected field.
    *    @param headerRelated Id of the related survey mapping.
    */
    setFieldSelected : function(nameFieldSelected, headerRelated){
        this.set(MODIFIED_ATTR, true);
        var comboRelated      = _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == headerRelated; });
        var fieldList         = comboRelated.get(FIELD_LIST_ATTR);
        _.each(fieldList, function(field){field.selected = field.value == nameFieldSelected;return false; });
    },

    /**
    *    Create mapped field data of the question (JSON format).
    */
    getMappedFields : function(){
        var self              = this;
        var childrenList      = this.get(CHILDREN_ATTR);
        var childrenDataArray = [];
        _.each(childrenList, function(child){
            var childData                    = {};
            var selectedField                = _.find(child.get(FIELD_LIST_ATTR), function(field){ return field.selected == true; });
            childData.required               = selectedField.required;
            childData.relatedHeaderCombo     = child.get(RELATED_COMBO_ATTR);
            childData.questionId             = self.get('Id');
            childData.mappedFieldName        = selectedField.value;
            childrenDataArray.push(childData);
        });
        return childrenDataArray;
    },

    rerender : function(){
        this.trigger("change:childrenMappedFields");
    },

    /**
    *    Deletes all children (Question mapping) of the question.
    */
    removeChildren : function(){
        this.set({childrenMappedFields: new Array()});
    },

    /**
    *    Iterates over children map of the given id of survey mapping, looking for repeated fields selected, if find one, set the question mapping as repeated.
    */
    setFieldAlreadySelected : function(fieldSelected, idSurveyMap, nameOfQuestionRepeated){
        var comboRelated         = _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == idSurveyMap; });
        var fieldListOfCombo     = comboRelated.get(FIELD_LIST_ATTR);
        var fieldSelectedData    = _.find(fieldListOfCombo, function(field){ return field.selected == true && field.value == fieldSelected && field.value != UNDEFINED_VALUE ; });
        var isFieldSelected      = isNotUndefined(fieldSelectedData);
        if(isFieldSelected) {
            comboRelated.set(CHILDREN_REPEAT_ATTR, nameOfQuestionRepeated);
            this.rerender();
        }
    },

    /**
    *    Removes questions mappings with error when a question mapping repeated changes its status.
    */
    removeErrorForAnotherQuestion : function(fieldSelected, idSurveyMap){
        var comboRelated         = _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == idSurveyMap; });
        var fieldListOfCombo     = comboRelated.get(FIELD_LIST_ATTR);
        var fieldSelectedData    = _.find(fieldListOfCombo, function(field){ return field.selected == true && field.value == fieldSelected && field.value != UNDEFINED_VALUE ; });
        var isFieldSelected      = isNotUndefined(fieldSelectedData);
        if(isFieldSelected) {
            comboRelated.set(CHILDREN_REPEAT_ATTR, false);
            this.rerender();
        }
    },

    /**
    *    Given a Survey mapping Id, deletes question mappings related to that Survey mapping.
    *    @param Id of the Survey mapping.
    */
    removeChildrenFromSMId : function(idSM){
        var comboChildrenNew    = _.filter(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) != idSM; });
        this.set({childrenMappedFields: comboChildrenNew});
        this.rerender();
    },

    /**
    *    Algorithm to order fields by label.
    */
    customSortByName : function(a, b){
         var nameA = a.label.toLowerCase(), nameB = b.label.toLowerCase()
         if (nameA < nameB) //sort string ascending
          return -1
         if (nameA > nameB)
          return 1
         return 0 //default return value (no sorting)
    },

    /**
    *    Given a survey Mapping Id, and the name of a field, returns true if this question
    *    has that field selected for the question mapping related to the survey mapping.
    *    @param idSurveyMapping Id of survey mapping.
    *    @param nameField Name of the field.
    */
    hasFieldInUse : function(idSurveyMapping, nameField){
        var relatedCombo = this.getComboRelated(idSurveyMapping);
        var isFieldInUse = _.find(relatedCombo.get(FIELD_LIST_ATTR), function(field){ return field.selected && field.value == nameField && field.value != UNDEFINED_VALUE ; });
        return isNotUndefined(isFieldInUse);
    },

    /**
    *    Given a survey Mapping Id, and the name of a field, returns true if this question
    *    is selected for the question mapping related to the survey mapping.
    *    @param idSurveyMapping Id of survey mapping.
    */
    hasQMSetted : function(idSurveyMapping){
        var relatedCombo = this.getComboRelated(idSurveyMapping);
        var isFieldInUse = _.find(relatedCombo.get(FIELD_LIST_ATTR), function(field){ return field.selected && field.value != UNDEFINED_VALUE ; });
        return isNotUndefined(isFieldInUse);
    },

    /**
     * This method set if the select of the question mapping (related to the survey mapping id) should be disabled or not.
     * @param idSurveyMapping Survey mapping id.
     * @param isDisabled True if should be disabled, false otherwise.
     */
    setQuestionMappingDisableCombo: function(idSurveyMapping, isDisabled){
        var relatedCombo = this.getComboRelated(idSurveyMapping);
        relatedCombo.set('disable', isDisabled);
        this.rerender();
    },

    /**
     * This method set if the select of the question mapping (related to the survey mapping id) should be disabled or not.
     * @param idSurveyMapping Survey mapping id.
     * @param shouldBeDisable True if should be disabled, false otherwise.
     */
    setQuestionMappingVisibility : function(idSurveyMapping, shouldBeDisable){
        var relatedCombo = this.getComboRelated(idSurveyMapping);
        relatedCombo.set(DISABLE_REPEATED, shouldBeDisable);
        this.rerender();
    },

    /**
     * Returns the name of the field that is selected for the given survey mapping Id.
     * @param Survey mapping Id.
     * @return Name of the selected field.
     */
    getFieldRelatedOfSurveyMapping : function(smId){
        var relatedCombo = this.getComboRelated(smId);
        var fieldInUse = _.find(relatedCombo.get(FIELD_LIST_ATTR), function(field){ return field.selected });
        return (isNotUndefined(fieldInUse)) ? fieldInUse.value : '-1';
    },

    /**
     *  Method in charge to remove error on this question for the question mapping related to the given survey mapping.
     *  @param smId Survey mapping Id.
     */
    removeErrorOnQuestionMapping : function(smId){
        var relatedCombo = this.getComboRelated(smId);
        relatedCombo.set(CHILDREN_REPEAT_ATTR, false);
        this.rerender();
    }

});

//    Different type of questions, in the default method sets at least : type and map of field types
//    that filters the fields of the selected object.

var QuestionNumeric = Question.extend({

});

var QuestionDecimal = QuestionNumeric.extend({

    defaults :{
        type                 : 'decimal',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'DOUBLE', 'CURRENCY', 'PERCENT']
    }

});

var QuestionInteger = QuestionNumeric.extend({

    defaults :{
        type                 : 'integer',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'DOUBLE', 'INTEGER', 'CURRENCY', 'PERCENT']
    }
});

var QuestionText = Question.extend({

    defaults :{
        type                 : 'text',
        mapAllowedFields     : ['STRING', 'TEXTAREA']
    }
});

var QuestionTextLong = Question.extend({

    defaults :{
        type                 : 'textLong',
        mapAllowedFields     : ['TEXTAREA']
    }
});

var QuestionBarcode = Question.extend({

    defaults :{
        type                 : 'barcode',
        mapAllowedFields     : ['STRING', 'TEXTAREA']
    }
});

var QuestionAbstractDate = Question.extend({

});

var QuestionDate = QuestionAbstractDate.extend({

    defaults :{
        type                 : 'date',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'DATE']
    }
});

var QuestionDateTime = QuestionAbstractDate.extend({

    defaults :{
        type                 : 'dateTime',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'DATETIME']
    }
});

var QuestionSingleSelect = Question.extend({

    initialize: function(){
        this.set('positionSelected', UNDEFINED_VALUE);
        this.set({childrenMappedFields: new Array()});
    },

    defaults :{
        type                 : 'selectRadio',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'PICKLIST']
    }
});

var QuestionMultiSelect = Question.extend({

    initialize: function(){
    this.set('positionsSelected', new Array());
    },

    defaults :{
        type                 : 'select',
        mapAllowedFields     : ['STRING', 'TEXTAREA', 'MULTIPICKLIST']
    }
});

var QuestionStaticContent = Question.extend({

    defaults :{
        type                 : 'static',
        mapAllowedFields     : []
    }
});

var QuestionEndOfSurvey = Question.extend({

    defaults :{
        type                 : 'end_of_survey',
        mapAllowedFields     : []
    }
});

var FakeQuestion = Question.extend({
    // This is not a question, but sometimes we need to use other elements as questions, so we use this.
    defaults :{
        type                 : 'fake'
    }
});

//    Model that represents a section.
var Section = AbstractQuestion.extend({

    initialize: function(){
        this.set('childrenSize', 0);
        this.set(NUMBER_HEADER_ATTR, '');
    },

    /**
    *    Set "children" size to the Section (section doesn't have children, but in order to keep in
    *    sync with the list of questions we need to create dummy list of children).
    */
    setChildrenSize : function(childrenLength){
        this.set('childrenSize', childrenLength);
        this.trigger("change:childrenSize");
    }
});

var SectionFieldList = Section.extend({
    initialize: function(){
        this.isListField = true;
    }
});

var SectionSimple = Section.extend({
    initialize: function(){
        this.isListField = false;
    }
});

/* Superclass of the mapping with special rules (As survey, etc) */
var SpecialQuestion = Question.extend({

    /* This function filter the combo according the mapping rule of the object*/
    setFieldsToCombo: function(classSelected, fieldList, objectName, surveyMappedFields, listFieldSelected){
        this.fieldList          = fieldList
        var self                = this;
        var comboRelated        = _.find(this.get(CHILDREN_ATTR), function(child){ return child.get(RELATED_COMBO_ATTR) == classSelected; });
        var comboData           = [];
        var dummyUsedFields     = {};
        comboData.push({value: UNDEFINED_VALUE, label: UNDEFINED_LABEL, selected: true});
        // if it was retrieved from the DB, we save the object of the current survey submission field, and selected survey.
        if(surveyMappedFields) var objectNameSelected = surveyMappedFields[self.get('apiFieldName')];

        _.each(fieldList, function(field){
            //mappeableRule is a function to be implemented in each specialQuestionType
            //and tell us if field is mappeable to this question
            if (self.mappeableRule(field)){
                var isSelected =  (objectNameSelected == field.name) ? true : false;
                if(isSelected) {
                    self.set(MODIFIED_ATTR, true);
                    _.each(comboData, function(field){ if(field.selected == true) field.selected = false; });
                    var isListFieldSelected = (listFieldSelected == field.name);
                    self.setOptionToComboField(field.name, field.label, classSelected, isListFieldSelected);

                    // Adds the selected fields to the list of used fields.
                    fMPage.addFormatUsedField(dummyUsedFields, classSelected, self.get(ID_ATTRIBUTE), field.name);
                }
                comboData.push({value: field.name, label: field.label, selected: isSelected, required: field.required});
            }
        });
        fMPage.addUsedFields(dummyUsedFields);                      // Add field to the list of used fields.
        comboData.sort(this.customSortByName);
        comboRelated.set('sfobjectRelated', objectName);
        comboRelated.set(FIELD_LIST_ATTR, comboData);
        this.trigger("change:childrenMappedFields");
    },

    /* This function tell us whether the field is type compatible*/
    isCompatibleType:function(field){
        var isFieldInArray = false;
        var self = this;
        isFieldInArray     = _.contains(this.get('mapAllowedFields'), field.type);
        return isFieldInArray;
    },

    /*
    *    Create mapped field data of the question (JSON format).
    */
    getMappedFields : function(){
        var self             = this;
        var childrenList     = this.get(CHILDREN_ATTR);
        var childrenDataMap  = {};
        _.each(childrenList, function(child){
            var childData                     = {};
            var selectedField                 = _.find(child.get(FIELD_LIST_ATTR), function(field){ return field.selected == true; });
            childData.required                = selectedField.required;
            childData.mappedFieldName         = selectedField.value;
            childData.submissionName          = self.get('Id');
            childrenDataMap[child.get(RELATED_COMBO_ATTR)] = childData;
        });
        return childrenDataMap;
    }
});


var SurveySpecialQuestion = SpecialQuestion.extend({

    defaults : {
        Id:6,
        apiFieldName : 'Survey'
    },
    mappeableRule : function(field){
        return  field.relatedTo != null &&                                      // If is related to something...
                typeof _.find(field.relatedTo,                                  // and related to Survey__c
                function(rf){ return rf.name == SURVEY_NAME; }) != 'undefined';
    },
    mapAllowedFields :[]
});

var SurveyVersionSpecialQuestion = SpecialQuestion.extend({

    defaults : {
        Id:0,
        mapAllowedFields : ['DOUBLE', 'INTEGER'],
        apiFieldName : 'SurveyVersion'
    },

    mappeableRule : function(field){
        return ( field.relatedTo != null &&
                 typeof _.find(field.relatedTo,                                              // If is related to something...
                 function(rf){ return rf.name == SURVEY_VERSION_NAME; }) != 'undefined')     // and related to SurveyVersion__c...
                 || this.isCompatibleType(field);                                            // or if question type is mappeable.
    },

});

var SurveySubmissionSpecialQuestion = SpecialQuestion.extend({

    defaults :{
        Id:1,
        apiFieldName : 'Submission'
    },

    mappeableRule : function(field){
        return  field.relatedTo != null &&                                                  // If is related to something...
                typeof _.find(field.relatedTo,                                              // and related to Submission__c.
                function(rf){ return rf.name == SURVEY_SUBMISSION_NAME; }) != 'undefined' ;
    }
});

var SurveySurveyorSpecialQuestion = SpecialQuestion.extend({

    defaults :{
        Id:2,
        mapAllowedFields : ['STRING', 'TEXTAREA'],
        apiFieldName     : 'Surveyor'
    },

    mappeableRule : function(field){
        return (field.relatedTo != null &&
                typeof _.find(field.relatedTo,                                    // If is related to something...
                function(rf){ return rf.name == CONTACT_NAME; }) != 'undefined' ) // and related to Surveyor__c...
                || this.isCompatibleType(field);                                  // or if question type is mappeable.
    }
});

var SurveyIntervieweeSpecialQuestion = SpecialQuestion.extend({

    defaults :{
        Id:3,
        mapAllowedFields : ['STRING', 'TEXTAREA'],
        apiFieldName     : 'Interviewee'
    },

    mappeableRule : function(field){
        return (field.relatedTo != null &&
                typeof _.find(field.relatedTo,                                    // If is related to something...
                function(rf){ return rf.name == CONTACT_NAME; }) != 'undefined' ) // and related to Interviewee__c...
                || this.isCompatibleType(field);                                  // or if question type is mappeable.
    },

    /**
     * Method in charge to check if the question mapping related to the survey mapping Id, is setted.
     * @param smId Survey mapping Id
     * @return True if the relation is setted.
     */
    hasRespondedSetted : function(smId){
        var isSetted = false;
        var childQM  = this.getComboRelated(smId);
        if(isNotUndefined(childQM)){
            var fieldSelected = _.find(childQM.get(FIELD_LIST_ATTR), function(field){ return field.selected ; });
            isSetted          = fieldSelected.value != UNDEFINED_VALUE;
        }
        return isSetted;
    },

    /**
     * Method that set the question objects related to the given list as disabled in order
     * to avoid circular dependencies when the contact is child in an object relation.
     * @param listOfNewParentsOfContact List of ids of parents of the recently setted relation.
     * @param contactId Id of the checked contact (in order to avoid set the contact as disable because of contact).
     * @param disableAttribute Disable attribute that will be set to true (i.e. disable because are in
     * different repeats (DISABLE_SPECIAL_DIFF_REP), or because would create a circular dependency (DISABLE_SPECIAL_RELATION)).
     */
    setDisabledBecauseContact : function(listOfNewParentsOfContact, contactId, disableAttribute){
        var self = this;
        _.each(listOfNewParentsOfContact, function(idParent){
            if(idParent != contactId){
                // Set question mapping attribute disableBecauseRepeated true in each qm with id in list.
                var childQM  = self.getComboRelated(idParent);
                if(isNotUndefined(childQM)){
                    childQM.set(disableAttribute, true);
                }
            }
        });
    },

    /**
     *  Set DISABLE_SPECIAL_RELATION and DISABLE_SPECIAL_DIFF_REP attributes of all children of the respondent question false.
     */
    setAllRespondentEnabled : function(){
        _.each(this.get(CHILDREN_ATTR), function(child){
            // Set question mapping attribute disableBecauseRepeated false in each child.
            child.set(DISABLE_SPECIAL_RELATION, false);
            child.set(DISABLE_SPECIAL_DIFF_REP, false);
        });
    },

    /**
     *  Here we set the attribute 'disable' to false for the given survey mapping.
     *  @param Survey mapping Id.
     */
    enableDirectDisable : function(smId){
        var childQM  = this.getComboRelated(smId);
        if(isNotUndefined(childQM)){
            childQM.set('disable', false);
        }
    }
});

var SurveyPIIScoreSpecialQuestion = SpecialQuestion.extend({

    defaults :{
        Id:4,
        apiFieldName : 'PPIScore'
    },

    mappeableRule : function(field){
        return field.length >= 3;
    }
});

/* Model for storing which field is selected in each combo*/

var SelectedOptions = Backbone.Model.extend({

    initialize: function(){
        this.map = {};
    },

    /**
    *    Given a Survey mapping Id, return the values of selected fields for the given Survey mapping.
    *    @param Survey mapping Id.
    *    @return Object with values of the selected fields.
    */
    getValue : function(id){
        var element = null;
        if(isNotUndefined(this.map))
            element = this.map[id];
        return element
    },

    /**
     * Removes the field of the map.
     * @param name Survey mapping Id.
     * @param id Question mapping Id.
     */
     removeValue : function(name, id){
        if(isNotUndefined(this.map) && isNotUndefined(this.map[name])){
            this.map[name][id] = [];
        } 
     },

    /**
    *    Set the value of a recently selected selected question mapping.
    *    @param name Survey mapping Id.
    *    @param id Question mapping Id.
    *    @param selectedValue Value of the selected field.
    *    @param selectedOption Caption of the selected field.
    */
    setValue : function(name, id,selectedValue,selectedOption){
        if(typeof this.map == 'undefined') {this.map ={};}
        if (typeof this.map[name]!= 'undefined')
            this.map[name][id] = [selectedValue,selectedOption.replace(/\s+/g, ' ')];
        else{
            this.map[name] = {};
            this.map[name][id] = [selectedValue,selectedOption.replace(/\s+/g, ' ')];
        }
    },

    /**
    *    Given a Survey mapping Id and the caption of a field, returns true if the field is already selected.
    *    @param name Id of Survey mapping.
    *    @param selectedOption Caption of the selected field.
    *    @return True if field is already selected, false otherwise.
    */
    isSelectedValue: function(name,selectedOption){
        for(var id in this.map[name])
            if($.trim(this.map[name][id][0]) == $.trim(selectedOption)){
                return true;
            }
        return false;
    },

    /**
     * Set the all fieldmappings and filter the fields that are not unique
     * <p>
     *     We must use as id the Unique fields, the external ids, the field which is name of the object, the Salesforce Id or if object is Contact the LastName
     *
     * </p>
     * @param name Id of Survey mapping
     * @param fieldList The list
     */

    setFieldList : function(name,selectedObject, fieldList){

      var filterList = _.filter(fieldList, function(field) { return field.unique
                                                                || field.externalId
                                                                || field.nameField
                                                                || field.name=="Id"
                                                                || (selectedObject == 'Contact' && field.name == "LastName")});
      if(typeof this.validFieldsForId == 'undefined') this.validFieldsForId= {};
      this.validFieldsForId[name] = filterList;
    },

    /**
     * checks if the current fieldname is valid for showing in the ID combobox
     * @param name the current selectedCombo
     * @param fieldName the selected fieldname
     * @return true if the field should be shown in id combo box
     */
    isValidFieldForId: function(name,fieldName){
      if(typeof this.validFieldsForId != 'undefined')
      for( var a in this.validFieldsForId[name]){
        if (this.validFieldsForId[name][a].name == fieldName)
          return true;
      }
    return false;
  },
  /**
   * Method that looks for the name field for that survey mapping
   * @param name the name of the  survey mapping
   * @return the field that is name for that object
   */
  findNameField: function(name){

    if (this.validFieldsForId != null){
      for( var a in this.validFieldsForId[name]){
        if (this.validFieldsForId[name][a].nameField)
          return this.validFieldsForId[name][a];
      }
    }
    return null;
  },
    /**
    *    Given a Survey mapping Id, return the values of selected fields for the given Survey mapping in an array.
    *    @param Survey mapping Id.
    *    @return Array with values of the selected fields.
    */
    getSelectedOptionArray :function(name){
      var array =[];
      var isNameAdded = false;
      var nameField = null;
        if (typeof this.map != "undefined")
            for (var a in this.map[name]){
              if(this.isValidFieldForId(name,this.map[name][a][0])) //If the field can be an Id(Salesforce Id, unique, external id, name, or LastName if is contact
                array.push(this.map[name][a]);

            }
        //Looking for name field to added in the array
        nameField = this.findNameField(name);

        return array;
    },

    /**
    *    Method that return size of repeated fields for a given Survey mapping id.
    *    @param headerRelated Id of the survey mapping.
    *    @param nameFieldSelected value of the field selected.
    *    @return Field size of field with the given field for that survey mapping.
    */
    isFieldAlreadySelected : function(headerRelated, nameFieldSelected){
        var repeatedFieldLength = 0;
        if(isNotUndefined(this.map[headerRelated])){
            var mapOfRelatedQuestionFields  = this.map[headerRelated];
            var listRepeatedFields          = _.filter(mapOfRelatedQuestionFields, function(questMF){ return questMF[0] == nameFieldSelected ; });
            repeatedFieldLength             = listRepeatedFields.length;
        }
        //Obtain size of relations that have the given field as child for the given survey mapping (we treat those as set fields).
        var sizeOfRelations = fMPage.masterObjectCollection.getRelationsLengthOfGivenField(headerRelated, nameFieldSelected);

        return repeatedFieldLength + sizeOfRelations;
    }

},

    //static method
    {
        getInstance : function(){
            return globalSelectedOptions;
        }

    }

);
globalSelectedOptions = new SelectedOptions();

//-------------------------MasterObject model------------------------

var MasterObject = Backbone.Model.extend({

    initialize: function(){
        this.set({childrenRelations: new Array()});
        this.set({objectRelationsMapping : {}});
        this.set({'parentObject': { name: '-1', label: '-', id: undefined, hasRespondent : false, isInterviewee : false}});
    },

    /**
     *  This method is in charge of set the list of relations that are related to the changed object.
     *  @param Object relations of the object (ObjectRelationshipMapping__c).
     */
    setRelationFields : function(allObjectsRelations){
        var self = this;
        var listRelations = [];
        for(var i in allObjectsRelations){
            var listOfFieldsCoincident = _.filter(allObjectsRelations[i].parentsRelations, function(obj){ return obj.parent == self.get(PARENT_OBJECT_ATTR).name; });
            if(listOfFieldsCoincident.length > 0){
                 for(var e in listOfFieldsCoincident){
                     var newRelation = new RelationModel();
                     newRelation.set(CHILD_ATTR, allObjectsRelations[i].childObject);
                     newRelation.set(FIELD_LABEL_ATTR, listOfFieldsCoincident[e].fieldLabel);
                     newRelation.set(FIELD_NAME_ATTR, listOfFieldsCoincident[e].fieldName);
                     newRelation.set(FIELD_TYPE_ATTR, listOfFieldsCoincident[e].relationType);
                     listRelations.push(newRelation);
                 }
            }
        }
        this.set(CHILDREN_RELATIONS, listRelations);
    },

    /**
    *   This method creates a map with the form : <{{Children.Name}}, {{Relation Object}}[]> of the related fields.
    */
    getMapOfRelatedFields : function(){
        var mapRelatedFields = {};
        var relationsList = this.get(CHILDREN_RELATIONS);
        _.each(relationsList, function(relation){
            if (typeof mapRelatedFields[relation.get(CHILD_ATTR)] == 'undefined') {
                mapRelatedFields[relation.get(CHILD_ATTR)] = _.filter(relationsList, function(rel){ return rel.get(CHILD_ATTR) == relation.get(CHILD_ATTR); });
            }
        });
        return mapRelatedFields;
    },

    /**
    *   Set the related field names to the list of object relations.
    */
    setRelatedFieldNames : function(idChildSurveyMapping, listRelatedFields){
        var dummyFieldsRelated = this.get(OBJECT_RELATIONS_MAPPINGS);
        dummyFieldsRelated[idChildSurveyMapping] = listRelatedFields;
        this.set(OBJECT_RELATIONS_MAPPINGS, dummyFieldsRelated);
    },

    /**
    *   Collects the relation data of the master object.
    */
    obtainRelationsData : function(){
        var listRelationChild = [];
        _.each(this.get(OBJECT_RELATIONS_MAPPINGS), function(rel, childId){
             if(_.size(rel) > 0){
                var listRelatedNames = [];
                _.each(rel, function(rf){ listRelatedNames.push(rf.name); });
                var relChild = {'child' : childId, 'fieldsRelated' : listRelatedNames};
                listRelationChild.push(relChild);
             }
        });
        return listRelationChild;
    },

    /**
    *   Modifies the data in the list of survey mappings.
    *   @param surveyMappingId Id of the survey mapping.
    *   @param fieldName Name of the selected field.
    *   @param fieldLabel Label of the selected field.
    */
    modifyPossibleSurveyMappings : function(surveyMappingId, fieldName, fieldLabel){
        if(isNotUndefined(this.get(POSSIBLE_MAPPINGS)) && this.get(POSSIBLE_MAPPINGS).length > 0){
            var smToChange = _.find(this.get(POSSIBLE_MAPPINGS), function(sm){ return sm.get(ID_ATTR) == surveyMappingId; });
            smToChange.set(OBJECT_NAME_ATTR, fieldName);
            smToChange.set(OBJECT_LABEL_ATTR, fieldLabel);
        }
    },

    /**
    *   Removes the Object relations that had the deleted survey mapping as child.
    *   @param Id of the Survey mapping deleted.
    */
    removeRelationsofSm : function(surveyMappingId){
        if (isNotUndefined(this.get(OBJECT_RELATIONS_MAPPINGS)[surveyMappingId])) {
              this.get(OBJECT_RELATIONS_MAPPINGS)[surveyMappingId] = [];
        }
    },

    /**
    *   Modify the parent data of the master object.
    *   @param surveyMappingId Id of the survey mapping.
    *   @param fieldName Name of the selected field.
    *   @param fieldLabel Label of the selected field.
    */
    modifyIfParentObject : function(surveyMappingId, fieldName, fieldLabel){
        var attrParentId = this.get(PARENT_OBJECT_ATTR).id;
        if( isNotUndefined(attrParentId) && attrParentId == surveyMappingId){
            this.set(PARENT_OBJECT_ATTR, {id : surveyMappingId, label : fieldLabel, name : fieldName});
            this.set(OBJECT_RELATIONS_MAPPINGS, {});
            this.set(CHILDREN_RELATIONS, []);
        }
    },

    /**
    *   Modifies the data of the changed Survey mapping.
    *   @param surveyMappingId Id of the survey mapping.
    *   @param fieldName Name of the selected field.
    *   @param fieldLabel Label of the selected field.
    */
    modifySMRelatedData : function(surveyMappingId, fieldName, fieldLabel){
        this.modifyPossibleSurveyMappings(surveyMappingId, fieldName, fieldLabel);
        this.removeRelationsofSm(surveyMappingId);
        this.modifyIfParentObject(surveyMappingId, fieldName, fieldLabel);
        this.rerender();
    },

    /**
    *   Adds a new survey mapping to the list of the Master object.
    */
    addNewSM : function(surveyMappingId){
        var listWithSurveyMapping = _.filter(this.get(POSSIBLE_MAPPINGS), function(sm){ return sm.get(ID_ATTR) == surveyMappingId; });
        if(listWithSurveyMapping.length == 0){
            var listOfPossibleMappings = this.get(POSSIBLE_MAPPINGS);
            var newSM = new SurveyMapping({'id' : surveyMappingId});
            listOfPossibleMappings.push(newSM);
            this.set(POSSIBLE_MAPPINGS, listOfPossibleMappings);
        }
    },

    rerender : function(){
        this.trigger("change:objectRelationsMapping");
    },

    /**
    *   Removes the Survey mapping from the master object.
    *   Also deletes the object relations that had the deleted survey mapping as child.
    *   @param Id of the survey mapping deleted.
    */
    removeSM : function(surveyIdToDelete){
        var listOfPossibleMappings = _.filter(this.get(POSSIBLE_MAPPINGS), function(sm){ return sm.get(ID_ATTR) != surveyIdToDelete; });
        this.set(POSSIBLE_MAPPINGS, listOfPossibleMappings);
        this.removeRelationsofSm(surveyIdToDelete);
        this.rerender();
    },

    /**
     * Set previously saved related objects to the master object.
     * @param Object relations retrieved from the DB.
     */
    setSavedObjectRelated : function(savedObjectRelations){
        var self                 = this;
        var newListRelatedObject = {};
        var dummyUsedFields      = {};
        var listOfRelatedMine    = _.filter(savedObjectRelations, function(or){ return or.parentSM == self.get(PARENT_OBJECT_ATTR).id; });
        _.each(listOfRelatedMine, function(relatedObject){
            // Here we retrieve data of the related field (name, label and type of relation) need to look in childrenRelations, because in the DB we only save the name of the field.
            var nameOfChildData     = _.find(self.get(POSSIBLE_MAPPINGS), function(pm){ return pm.get(ID_ATTR) == relatedObject.childSM; });
            var dataOfRelatedObject = _.find(self.get(CHILDREN_RELATIONS), function(mof){ return mof.get(CHILD_ATTR) == nameOfChildData.get(OBJECT_NAME_ATTR) && mof.get(FIELD_NAME_ATTR) == relatedObject.fieldName; });
            var savedRelation       = {}
            savedRelation.name      = dataOfRelatedObject.get(FIELD_NAME_ATTR);
            savedRelation.label     = dataOfRelatedObject.get(FIELD_LABEL_ATTR);
            savedRelation.relation  = dataOfRelatedObject.get(FIELD_TYPE_ATTR);

            // Add the field to the list of used fields.
            fMPage.addFormatUsedField(dummyUsedFields, nameOfChildData.get(ID_ATTR), self.get(PARENT_OBJECT_ATTR).id, savedRelation.name);
            // Create the list of fields (or add the element if its already created).
            var listFieldsOfChild  = (isNotUndefined(newListRelatedObject[relatedObject.childSM])) ? newListRelatedObject[relatedObject.childSM] : [];
            listFieldsOfChild.push(savedRelation);
            newListRelatedObject[relatedObject.childSM] = listFieldsOfChild;
            // If the relation field is master-detail set the field to the list of fields selected.
            if(savedRelation.relation == MASTER_DETAIL_RELATION){
                globalSelectedOptions.setValue(nameOfChildData.get(ID_ATTR), savedRelation.name, savedRelation.name, savedRelation.label);
            }
        });
        fMPage.addUsedFields(dummyUsedFields);                     // Add field to the list of used fields.
        this.set(OBJECT_RELATIONS_MAPPINGS, newListRelatedObject); // Set saved relations to the master object.
    },

    /**
     *  Obtain true if there is a relation for the given field where the child is the given survey mapping Id.
     *  @param smId Survey mapping Id.
     *  @param fieldName Field name.
     *  @return True if there is a relation for the given field where the child is the given survey mapping Id, false otherwise.
     */
    hasRelationForGivenField : function(smId, fieldName){
        var hasRelation         = false;
        var relationsOfChildren = this.get(OBJECT_RELATIONS_MAPPINGS)[smId];
        if(isNotUndefined(relationsOfChildren)){
            var relationObject = _.find(relationsOfChildren, function(relation){ return relation.name == fieldName; });
            hasRelation        = isNotUndefined(relationObject); 
        }
        return hasRelation;
    },

    /**
     *  Method in charge to return a version of {this} but in the form of a "Fake" question in order to
     *  be able to handle message errors (because of repeated fields and relations) in an easy way. 
     */
    castToFakeQuestion : function(){
        var fakeQuestion = new FakeQuestion();
        fakeQuestion.set(ID_ATTR, this.get(PARENT_OBJECT_ATTR).id);
        fakeQuestion.set(NUMBER_HEADER_ATTR, fieldRepeatedOnRelation.format([ this.get(PARENT_OBJECT_ATTR).label ]));
        return fakeQuestion;
    },

    /**
     *  Method in charge to set the related survey mapping of the given Id disabled because
     *  is mapped to different repeat section than {this}.
     *  @param Child Survey mapping Id.
     */
    setRelationDisabledBecauseDiffRepeats : function(childId){
        var listDisabledChildrenBecauseDiffRepeats = this.get(DISABLE_DIFF_REPEATS);
        if(!isNotUndefined(listDisabledChildrenBecauseDiffRepeats)){
            listDisabledChildrenBecauseDiffRepeats = new Array();
        }
        listDisabledChildrenBecauseDiffRepeats.push(childId);
        this.set( DISABLE_DIFF_REPEATS , listDisabledChildrenBecauseDiffRepeats);
    },

    /**
     *  Removes the list of disabled relations because are mapped to different repeat sections.
     */
    removeDisabledRelations : function(){
        this.set(DISABLE_DIFF_REPEATS, new Array());
    },

    /**
     * Set hasRespondent attribute of {this}.
     * @param isEmpty Boolean that will be the opposite of the value of hasAttribute.
     */
    setRespondent : function(isEmpty){
        var parentObj = this.get(PARENT_OBJECT_ATTR);
        parentObj.hasRespondent = !isEmpty;
    }
});

var RelationModel = Backbone.Model.extend({

    initialize: function(){

    }

});

var SurveyMapping = Backbone.Model.extend({

    initialize: function(){

    }

});

/**
 *    This model represents how the objects relate each order in order to avoid circular relations.
 *    The objects holds its own id, and an array of id of parents.
 */
var NodeModel = Backbone.Model.extend({

    initialize: function(){
        this.set({parents: new Array()});
    },

    /**
     * Set parents of {this} as parent of the childNode (we know that childNode is a descendent of {this}).
     * @param childNode Object that is looking for its ancestors.
     * @param collectionModels Node parents-children collection.
     */
    setParentsRecursively : function(childNode, collectionModels){
        var parentsChildNode   = childNode.get(PARENTS_ATTR);
        var parentsCurrentNode = this.get(PARENTS_ATTR);
        var isAlreadySetted    = _.contains(parentsChildNode, this.get(ID_ATTR)); // True if {this} is already setted as parent of childNode.
        if(this.get(ID_ATTR) != childNode.get(ID_ATTR) && !isAlreadySetted){
            // Is not the same node, and is not setted as parent already, so we set it as parent.
            parentsChildNode.push(this.get(ID_ATTR));
        }
        if(parentsCurrentNode.length > 0){
            _.each(parentsCurrentNode, function(grandpaId){
                // Each ancestor of {this}.
                var grandpa = _.find(collectionModels, function(nodeModel){ return nodeModel.get(ID_ATTR) == grandpaId; });
                grandpa.setParentsRecursively(childNode, collectionModels);
            });
        }
    },

    /**
     * Adds ancestors of {this} to the listOfParents.
     * @param listOfParents List of parents ids.
     * @param collectionModels Node parents-children collection.
     */
    setAncestorsToList : function(listOfParents, collectionModels){
        if(!_.contains(listOfParents, this.get(ID_ATTR))){
            listOfParents.push(this.get(ID_ATTR));
        }
        var parentsCurrentNode = this.get(PARENTS_ATTR);
        _.each(parentsCurrentNode, function(grandpaId){
            // Each ancestor of {this}.
            var grandpa = _.find(collectionModels, function(nodeModel){ return nodeModel.get(ID_ATTR) == grandpaId; });
            grandpa.setAncestorsToList(listOfParents, collectionModels); 
        });
    },

    /**
     * Removes all parents of the current node.
     */
    removeParents : function(){
        this.set(PARENTS_ATTR, new Array());
    },

    /**
     *  Searches for each ancestor for the first one to have a repeatedId.
     *  @param surveyMappingList List of survey mappings.
     *  @param nodeList List of node relations.
     *  @return Id of the first repeated Id found, UNDEFINED_VALUE if no parent have repeat Id.
     */
    obtainRepeatIdOfAncestor : function(surveyMappingList, nodeList){
        var repeatedIdParent     = UNDEFINED_VALUE;
        var selfId               = this.get(ID_ATTR);
        // listOfRepeatedMappingsOfSm.length will be greater than 0 if  has a repeated section (not if it has it because is descendent of one that has).
        var listOfRepeatedMappingsOfSm = fMPage.getListOfFieldsInRepeatedSections(selfId);
        if(listOfRepeatedMappingsOfSm.length > 0){
            // Has Repeat Id because it has a field in the repeated section.
            var currentSurveyMapping = _.find(surveyMappingList, function(sm){ return sm.get(ID_ATTR) == selfId; });
            repeatedIdParent         = currentSurveyMapping.get(REPEAT_ID_ATTR);
        }
        else{
            // Has Repeat Id because is descendent of a survey mapping that has a field in the repeated section.
            var parentsCurrentNode = this.get(PARENTS_ATTR);
            for( var i = 0; i < parentsCurrentNode.length && repeatedIdParent == UNDEFINED_VALUE; i++ ){
                // Each parent of {this}.
                var grandpaId    = parentsCurrentNode[i];
                var grandpa      = _.find(nodeList.models, function(nodeModel){ return nodeModel.get(ID_ATTR) == grandpaId; });
                repeatedIdParent = grandpa.obtainRepeatIdOfAncestor(surveyMappingList, nodeList);
            }
        }
        return repeatedIdParent;
    },

    /**
     *  Method in charge to look for parents and children of the object, and set repeatedId for this, children and parents of this (and disable correct repeats).
     *  @param repeatedId Repeat Id to set to parents.
     *  @param nodeList Node parents-children collection.
     *  @param surveyMappingList List of survey mappings.
     *  @param listOfSmWithRepeat List of survey mappings with repeat already assigned.
     */
    setRepeatIdForMeAndRelatives : function(repeatedId, nodeList, surveyMappingList, listOfSmWithRepeat){
        fMPage.disableQMInRepeatedFromEvent(this.get(ID_ATTR), repeatedId);
        listOfSmWithRepeat.push(this.get(ID_ATTR));
        var parentsCurrentNode = this.get(PARENTS_ATTR);
        var self               = this;

        // Obtain the child nodes of the surveyMappingList that has {this} as ancestor...
        var childSmWithRepeat  = _.filter(surveyMappingList, function(sm){ return fMPage.nodeCollection.isAncestor(self.get(ID_ATTR), sm.get(ID_ATTR))});
        _.each(childSmWithRepeat, function(childObject){
            // Set repeat Id for each descendant of {this}.
            listOfSmWithRepeat.push(childObject.get(ID_ATTR));
            fMPage.disableQMInRepeatedFromEvent(childObject.get(ID_ATTR), repeatedId);
        });
        _.each(parentsCurrentNode, function(grandpaId){
            // Set repeat Id for each parent of {this} (and ancestor in a recursive way).
            var grandpa = _.find(nodeList.models, function(nodeModel){ return nodeModel.get(ID_ATTR) == grandpaId; });
            grandpa.setRepeatIdForMeAndRelatives(repeatedId, nodeList, surveyMappingList, listOfSmWithRepeat);
        });
    },

    /**
     *  Method in charge to find out if {this} is descendent of given Id.
     *  @param parentId Ancestor Id.
     *  @param nodeList Node parents-children collection.     
     *  @return True if parentId is ancestor of {this}, false otherwise.
     */
    isMyAncestor : function(parentId, nodeList){
        var foundAncestor      = false;
        var parentsCurrentNode = this.get(PARENTS_ATTR);
        for( var i = 0; i < parentsCurrentNode.length && !foundAncestor ; i++ ){
            // Each parent of {this}.
            var grandpaId = parentsCurrentNode[i];
            if(grandpaId == parentId){
                foundAncestor = true;
            }
            else{
                var grandpa   = _.find(nodeList.models, function(nodeModel){ return nodeModel.get(ID_ATTR) == grandpaId; });
                foundAncestor = grandpa.isMyAncestor(parentId, nodeList);
            }
        }
        return foundAncestor;
    }

});


//-------------------------Page model--------------------------------
//     This model will be changed in the future, for now we use it almost as a facade, but with logic in it.
var FieldMappingPage = Backbone.Model.extend({

    /**
    *    Model constructor
    *    @param tableSurvey Table to append data.
    *    @param questionsObject Data of questions.
    *    @param isPPI True if is a survey PPI.
    */
    initialize: function(tableSurvey, questionsObject, isPPI){
        this.surveyMappingNames  = [];                   // Names of current survey mappings
        this.surveyMappingFields = [];                   // Array of maps with the format <name of survey mapping, list of fields>
        this.repeatedSections    = [];                   // List of repeats sections.
        this.firstSurveyMappings = [];                   // List of SurveyMappings Id's retrieved from DB.
        this.usedFields          = {};                   // Map of used fields <childId, {objectName (Parent), fieldName}>
        this.nodeCollection      = new NodeCollection(); // List of nodes with references to parents and children (Master objects).
        this.renderSurveyMappings(tableSurvey, isPPI);
        this.renderQuestionCollection(tableSurvey, questionsObject);
        this.masterObjectCollection = new MasterObjectList();
        this.selectNumber = 0;
    },

    /**
    *    Adds a new field mapping column.
    *    @param surveyElem If called from a new column is false, if retrieved from the DB is the element of the clicked select combo.
    *    @param myHeaderColumn Object containing org objects.
    */
    addColumn : function(surveyElem, myHeaderColumn){
        var idSurvey = (surveyElem) ? surveyElem.Id : false;
        if(idSurvey) this.firstSurveyMappings.push(idSurvey);
        this.addHeaderColumn(surveyElem, myHeaderColumn);
        this.adaptSectionLength();
        this.questionCollection.createEmptyColumns(this.selectNumber, idSurvey);
        this.questionSubmissionCollection.createEmptyColumns(this.selectNumber, idSurvey);
    },

    /**
    *   Method in charge of create a header select, and populate it with the objects retrieved from the org.
    *    This will be changed later (to have survey mappings as models and views).
    *    @param surveyElem If called from a new column is false, if retrieved from the DB is the element of the clicked select combo.
    *    @param myHeaderColumn Object containing org objects.
    */
    addHeaderColumn : function(surveyElem, myHeaderColumn){
        //Add object values to the select of objects.
        var idSurvey = (surveyElem) ? surveyElem.Id : false;
        var headerColumnEl;
        var self = this;
        if(myHeaderColumn){
            if(!idSurvey) this.selectNumber++;
            var nameToRelate = (idSurvey) ? idSurvey : 'sc' + this.selectNumber;
            headerColumnEl = $('<select class="selectHeader" name="' + nameToRelate + '"  ></select>');
            headerColumnEl.append($('<option value="-1" >-</option>'));
            _.each(myHeaderColumn, function(objColumn){
                var optionColumn = $('<option value="' + objColumn.name + '" >' + objColumn.label + '</option>');
                headerColumnEl.append(optionColumn);
            });
            var repeatSectionAttr   = isNotUndefined(surveyElem.repeatIdSection) ? 'value="' + surveyElem.repeatIdSection + '"' : '';
            var newSelectContainer  = $('<td class="selectObjectContainer" ' + repeatSectionAttr + ' ></td>');
            var removeItem          = $('<span><a class="removeColumnAnchor" name="' + nameToRelate + '">' + removeLabel + '</a></span>')
            var selectedOption      = $('<select class="idFieldClass" name="'+ nameToRelate +'"></select>')
            selectedOption[0].options[selectedOption[0].options.length] = new Option(UNDEFINED_LABEL,UNDEFINED_LABEL);
            var aux = SelectedOptions.getInstance().getSelectedOptionArray(nameToRelate);
            var inputDiv = $('<div class="intervieweeContainer" name="'+ nameToRelate +'"><input type="checkbox" name="'+ nameToRelate +'" class="intervieweeCheckbox"></input>' + useAsIntervieewLabel + '</div>') ;

            if(surveyElem.objectMapped == CONTACT_NAME) {
                if(surveyElem.isInterviewee) $(inputDiv).find('.intervieweeCheckbox').attr(CHECKED_ATTR, CHECKED_ATTR);
            }
            else{
                inputDiv.hide();
            }
            self.bindClickCheckbox(inputDiv, nameToRelate);

            this.sortSelect(headerColumnEl);
            headerColumnEl[0].selectedIndex = 0; //Workaround for IE8.
            newSelectContainer.append(headerColumnEl);
            newSelectContainer.append(selectedOption);
            newSelectContainer.append(inputDiv);
            newSelectContainer.append(removeItem);
            $('.prevComboContainer').before(newSelectContainer);
        }
    },

    /**
    *    Method that binds click on .intervieweeCheckbox.
    */
    bindClickCheckbox : function(inputDiv, nameToRelate){
        var self      = this;
        $(inputDiv).find('input').bind("click", function(e){
            var acceptToRemoveId  = true; // User accept to remove id fields of descendents, or wasn't necessary to ask.
            var acceptRemoveResp  = true; // User accept to remove repondent, or wasn't necessary to ask.
            var question          = self.questionSubmissionCollection.getElementById(RESPONDENT_ID);
            var c                 = e.currentTarget;
            var isChecked         = $(c).attr(CHECKED_ATTR);
            var listOfSMSpecial   = self.obtainListSmWithIdFieldInRegularAndRespondent(question);
            var amIOnRepeated     = $(c).parent().parent().attr('value') != '';
            var isRespondentSet   = question.hasRespondedSetted(nameToRelate);

            if(isChecked && isRespondentSet){
                // This contact has respondent set, so we ask the user if is sure that he wants to remove respondent field
                acceptRemoveResp = confirm(setIntervieweeWillUnsetRespondent);
            }

            if(amIOnRepeated && isChecked && listOfSMSpecial.length > 0){
                // User checks "Use as interviewee" of {this}, {this} is associated to a repeated section, and there is
                // at least one survey mapping that has respondent set, and Id field in a regular question.
                acceptToRemoveId = confirm(setIntervieweeWillUnsetIdField);
                if(acceptToRemoveId){
                    // User accepts to remove Id fields that would create conflict.
                    _.each(listOfSMSpecial, function(smSp){
                        fMPage.removeIdField(smSp.get(ID_ATTR));
                    });
                }
            }

            if(acceptToRemoveId && acceptRemoveResp){
                // Enter here so the change on the checkbox will be done.
                hasUnsavedChanges = true;        
                if (isChecked){
                    $('.intervieweeCheckbox').each(function(i,e){
                        $(this).removeAttr(CHECKED_ATTR);
                        var currentContactId = $(this).attr('name');            
                        var comboRelated     = question.getComboRelated(currentContactId);
                        if(isNotUndefined(comboRelated)) comboRelated.set('disable',false);
                    });
                    $(inputDiv).find('input').attr(CHECKED_ATTR,CHECKED_ATTR);
                }
                var comboRelated = question.getComboRelated(nameToRelate);
                question.setFieldSelected(UNDEFINED_VALUE, nameToRelate);
                comboRelated.set('disable',isChecked==CHECKED_ATTR);
                // Have to remove the value of globalSelectedOptions also.
                if(isChecked==CHECKED_ATTR) globalSelectedOptions.setValue(nameToRelate, RESPONDENT_ID, UNDEFINED_VALUE, '-');
                
                self.setIntervieweeToMasterObjects(isChecked == CHECKED_ATTR, nameToRelate);
                self.refreshNodesParents();
                
                question.rerender();
            }
            else{
                // User didn't want to remove Id Fields, so we undo the action.
                e.preventDefault();
            }
        });
    },

    /**
     *  Return the list of survey mappings that has id field in regular question and has respondent set or are descendants
     *  of a survey mapping that has respondant set.
     *  @param respondentQuestion Respondent question.
     *  @return List of survey mappings that has respondent set, and id field in regular question.
     */
    obtainListSmWithIdFieldInRegularAndRespondent: function(respondentQuestion){
        var listOfSMWithRespondentAndDesc      = [];
        var listSm                             = retrieveSurveyMappings();
        var listOfSMWithRespondent = _.filter(listSm, function(sm){return respondentQuestion.hasRespondedSetted(sm.get(ID_ATTR)); });
        _.each(listOfSMWithRespondent, function(smSp){
            // If {this} (smSp) has Id field in regular section we add it to the list to return.
            if(fMPage.isIdFieldInRegularSection(smSp.get(ID_ATTR))) {
                listOfSMWithRespondentAndDesc.push(smSp);
            }
            // Also obtain and add descendants of {this} that has Id field in regular section.
            var descendentsOfSmSp         = fMPage.getDescendentsWithIdFieldInRegular(smSp.get(ID_ATTR));
            listOfSMWithRespondentAndDesc = listOfSMWithRespondentAndDesc.concat(descendentsOfSmSp);
        });
        return listOfSMWithRespondentAndDesc;
    },

    /**
    *    Given a combo select, sort the options alphabetically.
    *    @param Select combo to sort.
    */
    sortSelect : function(comboElement){
        $(comboElement).html($(comboElement).find("option").sort(function (a, b) {
            return a.text == b.text ? 0 : a.text < b.text ? -1 : 1
        }));
    },

    /**
     * Method in charge to set (or remove) isInterviewee attribute from master object
     * @param isChecked Status of the recently clicked checkbox.
     * @param smId Id of the survey mapping whose checkbox changed.
     */
    setIntervieweeToMasterObjects : function(isChecked, smId){
       this.masterObjectCollection.modifyIsInterviewee(smId, isChecked);
    },

    /**
    *    Method that call section collections and pass the question's children size, in order to
    *    keep section in sync with the questions.
    */
    adaptSectionLength : function(){
       var sizeOfColumns = $('.selectHeader:visible').length;
       this.sectionSubmissionCollection.rerenderAllSections(sizeOfColumns);
       this.sectionCollection.rerenderAllSections(sizeOfColumns);
    },

    /**
    *    Given a survey mapping Id, removes related child of each question.
    *    @param Survey mapping Id.
    */
    reloadQuestions : function(surveyIdToDelete){
        this.adaptSectionLength();
        this.questionSubmissionCollection.removeColumnFromId(surveyIdToDelete);
        this.questionCollection.removeColumnFromId(surveyIdToDelete);
    },

    /**
    *    This method call questions collection's completeComboFromObject method in order to fill the field of each question mapping, depending on
    *    the type of the question.
    */
    completeComboQMFromObject : function(fieldList, currentSelectedComboValue, currentSelectedCombo, submissionMap, listQuestionMapped, idFieldSelected){
        globalSelectedOptions.setFieldList(currentSelectedCombo,currentSelectedComboValue,fieldList);
        this.questionSubmissionCollection.completeComboFromObject(fieldList, currentSelectedComboValue, currentSelectedCombo, submissionMap, idFieldSelected);
        this.questionCollection.completeComboFromObject(fieldList, currentSelectedComboValue, currentSelectedCombo, listQuestionMapped, idFieldSelected);
    },

    /**
    *    Here we call each collection, and ask for data related.
    */
    getPageData : function(jsonDataSM){
        var arraySpecialQuestion = this.questionSubmissionCollection.getDataFromQuestionsChildren();
        var arrayQuestionsData   = this.questionCollection.getDataFromQuestionsChildren();
        var jsonToSendSF         = this.questionCollection.relateQuestionAndSurveyMapping(jsonDataSM, arrayQuestionsData, arraySpecialQuestion);
        return jsonToSendSF;
    },

    /**
    *    Call each question collection, and remove all question mappings for each question.
    */
    removeAllChildren : function(){
        this.questionSubmissionCollection.removeAllChildren();
        this.questionCollection.removeAllChildren();
    },

    /**
    *    When a question mapping is modified and has repeated fields (related to the survey mapping), calls this method to show a
    *    error message in each repeated field.
    *    @param headerRelated Id of the Survey mapping.
    *    @param nameFieldSelected Name of the selected field.
    *    @param questionWRepeatedFields List of questions that I already know have repeated fields.
    */
    setRepeatedValuesForCollection : function(headerRelated, nameFieldSelected, questionWRepeatedFields){
        this.setFieldSelectedForSM(nameFieldSelected, headerRelated, questionWRepeatedFields);
    },

    /**
    *    Given a id of survey mapping, the name of the selected field, and the list of questions with repeated fields,
    *    shows an error if field name is repeated for that survey mapping.
    *    @param fieldSelected Name of the selected field.
    *    @param idSurveyMap Id of the survey mapping.
    *    @param questionWRepeatedFields List of questions with repeated fields.
    */
    setFieldSelectedForSM : function(fieldSelected, idSurveyMap, questionWRepeatedFields){
        var firstQuestion = questionWRepeatedFields[0];
        var otherQuestion = questionWRepeatedFields[1];
        _.each(questionWRepeatedFields, function(quest){
            var nameToShowRepeated = ''
            if (firstQuestion.get(ID_ATTRIBUTE) != quest.get(ID_ATTRIBUTE)){
                nameToShowRepeated = (firstQuestion.get(NUMBER_HEADER_ATTR) != '') ? firstQuestion.get(NUMBER_HEADER_ATTR) : firstQuestion.get(CAPTION_ATTRIBUTE);
            }
            else{
                nameToShowRepeated = (otherQuestion.get(NUMBER_HEADER_ATTR) != '') ? otherQuestion.get(NUMBER_HEADER_ATTR) : otherQuestion.get(CAPTION_ATTRIBUTE);
            }
            if(quest.get('type') != 'fake'){
                quest.setFieldAlreadySelected(fieldSelected, idSurveyMap, nameToShowRepeated);
            }
        });
    },

    /**
    *    This method is in charge of remove errors (repeated fields) if necessary.
    *    @param headerRelated Id of the Survey mapping.
    *    @param nameFieldSelected Name of the selected field.
    */
    setFieldsWithoutError : function(headerRelated, nameFieldSelected){
        this.questionCollection.setFieldsUnselectedForSM(nameFieldSelected, headerRelated);
        this.questionSubmissionCollection.setFieldsUnselectedForSM(nameFieldSelected, headerRelated);
    },

    /**
    *    Returns a list of the objects that have at least on required field not mapped, and its required fields.
    *    @return List with the format : [Object, field.name, field.label]
    */
    validateAllRequiredFieldisBeingUsed : function (){
        var toReturn = [];
        for (var i in mapObjectIdToRequiredFields){
            var requiredField = mapObjectIdToRequiredFields[i]
            for(var j in requiredField){
                if (!globalSelectedOptions.isSelectedValue(i,requiredField[j].name)){
                    toReturn.push([i,requiredField[j].name, requiredField[j].label]);
                }
            }
        }
        return toReturn;
    },

    /**
     *  Creates submission mapping model (they are not a question, but behaves like one), view, and populates it.
     *    @param tableSurvey Table to append the special questions.
     *    @param isPPI True if survey is PPI.
     */
    renderSurveyMappings : function(tableSurvey, isPPI){

        var questionModelSD;
        var questionView;

        var sectionSubmissionList = [];
        var questionModelSD = new Section();
        questionModelSD.set(CAPTION_ATTRIBUTE, SECTION_SUBMISSION_LABEL);
        var questionView = new SectionRowViewFM({model:questionModelSD});
        tableSurvey.append(questionView.render());
        sectionSubmissionList.push(questionModelSD);

        this.sectionSubmissionCollection = new SectionList(sectionSubmissionList);
        var questionSubmissionList = [];

        questionModelSD = new SurveySpecialQuestion();
        questionModelSD.set(CAPTION_ATTRIBUTE, SURVEY_LABEL);
        questionView = new QuestionRowViewFM({model:questionModelSD});
        tableSurvey.append(questionView.render());
        questionSubmissionList.push(questionModelSD);

        var surveyVersionModel = new SurveyVersionSpecialQuestion();
        surveyVersionModel.set(CAPTION_ATTRIBUTE, SURVEY_VERSION_LABEL);
        var surveyVersionView = new QuestionRowViewFM({model:surveyVersionModel});
        tableSurvey.append(surveyVersionView.render());
        questionSubmissionList.push(surveyVersionModel);

        var submissionModel = new SurveySubmissionSpecialQuestion();
        submissionModel.set(CAPTION_ATTRIBUTE, SURVEY_SUBMISSION_LABEL);
        var submissionView = new QuestionRowViewFM({model:submissionModel});
        tableSurvey.append(submissionView.render());
        questionSubmissionList.push(submissionModel);

        var surveySurveyorModel = new SurveySurveyorSpecialQuestion();
        surveySurveyorModel.set(CAPTION_ATTRIBUTE, SURVEY_SURVEYOR_LABEL);
        var surveySurveyorView = new QuestionRowViewFM({model:surveySurveyorModel});
        tableSurvey.append(surveySurveyorView.render());
        questionSubmissionList.push(surveySurveyorModel);

        var surveyIntervieweeModel = new SurveyIntervieweeSpecialQuestion();
        surveyIntervieweeModel.set(CAPTION_ATTRIBUTE, SURVEY_INTERVIEEW_LABEL);
        var surveyIntervieweeView = new QuestionRowViewFM({model: surveyIntervieweeModel});
        tableSurvey.append(surveyIntervieweeView.render());
        questionSubmissionList.push(surveyIntervieweeModel);

        if(isPPI){
            var surveyPPIScoreModel = new SurveyPIIScoreSpecialQuestion();
            surveyPPIScoreModel.set(CAPTION_ATTRIBUTE, SURVEY_PPI_LABEL);
            var surveyPPIView = new QuestionRowViewFM({model: surveyPPIScoreModel});
            tableSurvey.append(surveyPPIView.render());
            questionSubmissionList.push(surveyPPIScoreModel);
        }
        this.questionSubmissionCollection = new QuestionList(questionSubmissionList);
    },

     /**
     *  Creates questions model, view, and populates the question collection.
     *    @param tableSurvey Table to append the special questions.
     *    @param questionsObject Data with questions.
     */
     renderQuestionCollection : function(tableSurvey, questionsObject){
        var questionList      = [];
        var sectionList       = [];
        var questionNumber    = 1;
        var sectionNumber     = 1;
        this.repeatedSections = []
        var self              = this;
        _.each(questionsObject , function(q){
            var questionModel;
            var questionView;
            if(q.Type.toLowerCase() == SECTION_NAME || q.Type.toLowerCase() == SECTION_REPEAT){
                if (q.Type.toLowerCase() == SECTION_REPEAT) self.repeatedSections.push(q.Id);
                questionModel = new Section();
                questionModel.set(ID_ATTRIBUTE, q.Id);
                questionModel.set(SECTION_ATTR, q.Type.toLowerCase());
                questionModel.set(CAPTION_ATTRIBUTE, q.Caption);
                questionModel.set(NUMBER_HEADER_ATTR, 'S' + sectionNumber);
                sectionList.push(questionModel);
                questionView = new SectionRowViewFM({model:questionModel});
                sectionNumber++;
            }
            else{
                questionModel     = self.createQuestionFromType(q.Type);
                var belongsRepeat = _.contains(self.repeatedSections, q.parentId);
                questionModel.set(CHILDREN_ATTR, new Array());
                questionModel.set(CAPTION_ATTRIBUTE, q.Caption);
                questionModel.set(ID_ATTRIBUTE, q.Id);
                questionModel.set(REQUIRED_ATTR, q.Required);
                questionModel.set(PARENT_ATTR, q.parentId);
                questionModel.set(NUMBER_HEADER_ATTR, 'Q' + questionNumber );
                questionModel.set(BELONGS_REPEAT, belongsRepeat);
                questionNumber++;
                questionList.push(questionModel);
                questionView = new QuestionRowViewFM({model:questionModel});
            }
            tableSurvey.append(questionView.render());
        });
        // Now we create the collection of questions to work with.
        this.sectionCollection   = new SectionList(sectionList);
        this.questionCollection  = new QuestionList(questionList);
    },

    /**
    *    Given a type of question, creates a new question for that type.
    *    @param Type of question.
    *    @return Question.
    */
    createQuestionFromType : function(type){
        var question;
        switch(type){
            case 'text-short'        : question = new QuestionText();break;
            case 'text-long'         : question = new QuestionTextLong();break;
            case 'checkbox'          : question = new QuestionMultiSelect();break;
            case 'radio'             : question = new QuestionSingleSelect();break;
            case 'number-decimal'    : question = new QuestionDecimal();break;
            case 'number-integer'    : question = new QuestionInteger();break;
            case 'date-date'         : question = new QuestionDate();break;
            case 'date-datetime'     : question = new QuestionDateTime();break;
            case 'barcode'           : question = new QuestionBarcode();break;
            case 'static-content'    : question = new QuestionStaticContent();break;
            case 'end_of_survey'     : question = new QuestionEndOfSurvey();break;
        }
        return question;
    },

    /**
    *    Disable intervieew field of the survey mapping that will be used as intervieew, when retrieving data from the DB.
    */
    disableIntervieew : function(nameToDisable){
        var questionIntervieew = this.questionSubmissionCollection.getElementById(RESPONDENT_ID);
        var comboRelated       = questionIntervieew.getComboRelated(nameToDisable);
        comboRelated.set('disable', true);
        questionIntervieew.rerender();
    },

    /**
    *    Method that retrieves questions that have repeated fields.
    *    @param headerRelated Id of the survey mapping related.
    *    @param nameFieldSelected Name of the selected field.
    *    @return Array of questions with fields repeated.
    */
    getQuestionsOfRepeatedFields : function(headerRelated, nameFieldSelected){
        var questionsRepeated         = this.questionCollection.obtainFieldsInUse(headerRelated, nameFieldSelected);
        var questionSpecialRepeated   = this.questionSubmissionCollection.obtainFieldsInUse(headerRelated, nameFieldSelected);
        var questionRelationRepeated  = this.masterObjectCollection.obtainFieldsInUse(headerRelated, nameFieldSelected);
        var joinedQuestions           = questionsRepeated.concat(questionSpecialRepeated, questionRelationRepeated);
        return joinedQuestions;
    },

    /**
     * This method creates one model (MasterObject) and its view, and returns it.
     * @param idSM Id of the survey mapping (fake id because its a recently created SurveyMapping).
     * @param listOfSurveyMappings List of survey mappings related to this survey.
     * @return View of the master object model created.
     */
    addMasterObject : function(idSM, listOfSurveyMappings){
        var newMasterObject       = new MasterObject({'possibleSurveyMappings' : listOfSurveyMappings});
        newMasterObject.set(PARENT_OBJECT_ATTR, {name: '-1', label: UNDEFINED_LABEL, id: idSM, idFieldLabel : UNDEFINED_LABEL});
        var newMasterObjectView   = new MasterObjectRowViewFM({model:newMasterObject});
        this.masterObjectCollection.push(newMasterObject);
        return newMasterObjectView.render();
    },

    /**
    *   Set fields, and relations between survey mappings.
    *   Also pass this data to the master objects.
    *   @param List of relations between objects.
    */
    setSMObjectRelations : function(surveyMapped){
        this.setSMFields(surveyMapped);
        this.setMapSmRelations();
        this.masterObjectCollection.setRelationFields(this.mapSmRelations);
    },

    /**
    *   Method in charge to collect object relations data, and returns it.
    *   @param List of master object data.
    */
    obtainRelationshipData : function(){
        return this.masterObjectCollection.obtainRelationsData();
    },

    /**
    *   Calls to the Master object collection passing the data of the recently changed
    *   survey mapping.
    *   @param surveyMappingId Id of the survey mapping.
    *   @param fieldName Name of the selected field.
    *   @param fieldLabel Label of the selected field.
    */
    modifySMRelatedData : function(surveyMappingId, fieldName, fieldLabel){
        this.masterObjectCollection.modifySMRelatedData(surveyMappingId, fieldName, fieldLabel);
    },

    /**
    *   Refresh the relations that the survey mappings have.
    *   @param objectName Name of object of the changed survey mapping.
    *   @param fieldList List of the fields of the object of the changed survey mapping.
    */
    addSMRefreshRelations : function(objectName, fieldList){
        this.addSMFields(objectName, fieldList);
        this.setMapSmRelations();
        this.masterObjectCollection.setRelationFields(this.mapSmRelations);
        this.masterObjectCollection.rerenderRelations();
    },

    /**
     * This method set the list of survey mappings related fields, and object names.
     * @param survey mapping relations.
     */
    setSMFields : function(surveyMapped){
        this.setSurveyMappingNames(surveyMapped);
        var self = this;
        _.each(surveyMapped, function(s){
            var listSMField = _.filter(self.surveyMappingFields, function(smF){ return smF.childObject == s.surveyMap.objectMapped });
            if(listSMField.length == 0){
                var smFullData = {};
                smFullData.childObject = s.surveyMap.objectMapped;
                smFullData.fieldList = s.relatedFields;
                self.surveyMappingFields.push(smFullData);
            }
        });
    },

    /**
     * This method set the relations between the survey mappings objects.
     */
    setMapSmRelations : function(){
        var smListRelatedFields  = [];
        var self = this;
        _.each(this.surveyMappingFields, function(s){
            // Iterate over the fields of each survey mapping...
            var smFieldsRelated = {};
            smFieldsRelated.childObject = s.childObject;
            var listRelatedFields = [];
            _.each(s.fieldList, function(field){
                // For each field, find related object in the list of survey mapping names.
                if(field.relatedTo != null && field.relatedTo.length > 0){
                    _.each(field.relatedTo, function(relField){
                        if(_.contains(self.surveyMappingNames, relField.name)){
                            // If the field have a relation with any of the objects, adds it to the list of relations.
                            var parentData = {fieldName : field.name, fieldLabel : field.label, parent : relField.name, relationType : relField.relationType};
                            listRelatedFields.push(parentData);
                        }
                    });
                }
            });
            smFieldsRelated.parentsRelations = listRelatedFields;
            smListRelatedFields.push(smFieldsRelated);
        });
        this.mapSmRelations = smListRelatedFields;
    },

    /**
    *   Sets the name of the survey mappings.
    *   @param Survey mappings data.
    */
    setSurveyMappingNames : function(surveyMapped){
        var self = this;
        this.surveyMappingNames = [];
        _.each(surveyMapped, function(sm){
            if(!_.contains(self.surveyMappingNames, sm.surveyMap.objectMapped)){
                self.surveyMappingNames.push(sm.surveyMap.objectMapped);
            }
        });
    },

    /**
    *   Adds the name of object related to the survey mapping to the list of survey mappings, and
    *   the fields of that object to the list of fields.
    */
    addSMFields :function (objectName, fieldList){
        if(!_.contains(this.surveyMappingNames, objectName)){
            this.surveyMappingNames.push(objectName);
            var newObjectSM = {};
            newObjectSM.childObject = objectName;
            newObjectSM.fieldList = fieldList;
            this.surveyMappingFields.push(newObjectSM);
        }
    },

    /**
    *   Adds an empty Master object.
    *   @param List of current survey mappings (in order to be capable of
    *   know which objects the master object will interact).
    */
    addSmToRelations : function(listOfSurveyMapping){
        this.nodeCollection.createNewNodeRelation('sc' + this.selectNumber);
        this.masterObjectCollection.createNewSurveyMapping('sc' + this.selectNumber);
        var newMasterObjectHtml = this.addMasterObject('sc' + this.selectNumber, listOfSurveyMapping);
        return newMasterObjectHtml;
    },

    /**
    *   Removes the recently deleted survey mapping of the list of the Master objects
    */
    removeSMOfRelatedObjects : function(surveyIdToDelete){
        this.masterObjectCollection.removeSM(surveyIdToDelete);
    },

    /**
    *   This method is only called when retrieving relations data from the server,
    *   is called after all empty master objects are created, and dump the server
    *   data in them.
    *   @param elem Element that the master object view will be appended.
    *   @param listSM List of the survey mappings.
    */
    setDefaultMasterObjects : function(elem, listSM){
        var self             = this;
        this.nodeCollection  = new NodeCollection();
        _.each(listSM, function(sm){
            var newNodeModel = new NodeModel();
            newNodeModel.set(ID_ATTR, sm.get(ID_ATTR));
            self.nodeCollection.add(newNodeModel);
            var newMasterObject = new MasterObject({'possibleSurveyMappings' : listSM});
            newMasterObject.set(PARENT_OBJECT_ATTR, {id : sm.get(ID_ATTR), name : sm.get(OBJECT_NAME_ATTR), label : sm.get(OBJECT_LABEL_ATTR), idFieldLabel : sm.get(ID_FIELD_LABEL), hasRespondent : sm.get(RESPONDENT_ATTR), isInterviewee : sm.get(INTERVIEWEE_ATTR)});
            var newMasterObjectView = new MasterObjectRowViewFM({model:newMasterObject});
            self.masterObjectCollection.push(newMasterObject);
            elem.after(newMasterObjectView.render());
            elem = $('.masterObjectRow').last();
        });
    },

    /**
     * This method load the previously saved relations into the master objects.
     * Also creates the nodes of parent relations.
     * @param listSM List of survey Mappings
     * @param savedObjectRelations Saved relations.
     */
    setPreviousRelations : function(listSM, savedObjectRelations){
        var self = this;
        this.nodeCollection.removeParentsOfNodes();               // Removes all parents nodes in order to set them again.
        _.each(listSM, function(sm){
            var newMasterObject = _.find(self.masterObjectCollection.models, function(mo){ return typeof mo.get(PARENT_OBJECT_ATTR) != 'undefined' && mo.get(PARENT_OBJECT_ATTR).id == sm.get(ID_ATTR); });
            newMasterObject.setSavedObjectRelated(savedObjectRelations);
            self.setParentsNodes(newMasterObject);
            if(sm.get(INTERVIEWEE_ATTR)){
              var listMasterWithResponded = self.getListOfMasterObjectIdRespondedSetted();
              self.setChildrenOfContactInterviewee(sm.get(ID_ATTR), listMasterWithResponded);
            }
        });
        this.nodeCollection.setAncestors();
        this.handleRepeatedVisibility();
        this.rerenderMasterObjects();
        this.refreshSpecialObjects();
    },

    /**
     *  This method collects ids of the children that the master object has relations with.
     *  Then set the parent ids to the node collection, only set one level deep, (set parents,
     *  not grand parents for example).
     *  @param Master object.
     */
    setParentsNodes : function(masterObject){
        var self = this;
        var listOfChildren = [];
        _.each(masterObject.get(OBJECT_RELATIONS_MAPPINGS), function(child, childId){
            if(typeof child != 'undefined' && child.length > 0){
                listOfChildren.push(childId);
            }
        });
        self.nodeCollection.setParentsNodes(masterObject.get(PARENT_OBJECT_ATTR).id, listOfChildren);
    },

    /**
    *   Calls the collection of master object in order to retrieve its data.
    */
    obtainObjectRelations : function(){
        return this.masterObjectCollection.obtainRelationsData();
    },

    rerenderMasterObjects : function(){
        this.masterObjectCollection.rerenderRelations();
    },

    /**
    *   Cleans the list of names, and list of fields of the page.
    */
    removeMappingNamesAndFields : function(){
        this.surveyMappingNames = [];
        this.surveyMappingFields = [];
    },

    removeMasterObject : function(){
        this.masterObjectCollection = new MasterObjectList();
        this.masterObjectCollection.rerenderRelations();
        this.removeMappingNamesAndFields();
    },

    /**
     * Called when changing a id field, set the label to the
     * Master object view.
     * @param idFieldId Id of the survey mapping whose idField change.
     * @param idFieldlabel New label of the idField.
     */
    setLabelIdField : function(idFieldId, idFieldlabel){
        this.masterObjectCollection.setNewLabelIdField(idFieldId, idFieldlabel);
    },

    /**
     * Method in charge of disable all question mapping of questions (with a repeated
     * section as parent) that are not in the section of the selected question mapping when retrieving data from DB.
     */
    disableQMOfRepeatedAtStart : function(){
        this.questionCollection.disableQMOfRepeated(this.firstSurveyMappings);
    },

    /**
     * Method called when a question mapping is setted by the user, in order to disable QM to other
     * questions inside of repeated sections.
     * Also 
     * @param smId Survey mapping Id.
     * @param parentSectionId Id of the parent section.
     */
    disableQMInRepeatedFromEvent : function(smId, parentSectionId){
        var questionOfRepSections = _.filter(this.questionCollection.models, function(q){ return q.get(BELONGS_REPEAT); });
        this.questionCollection.disableOtherQuestionOfRepeated(smId, questionOfRepSections, parentSectionId);
        this.setRepeatValueToSurveyMapping(smId, parentSectionId);
    },

    /**
     * Method called when a question mapping is removed by the user, in order to enable QM to other
     * questions inside of repeated sections.
     * @param smId Survey mapping Id.
     * @param parentSectionId Id of the parent section.
     */
    enableQMInRepeatedFromEvent : function(smId, parentSectionId){
        var numberOfEnableQuestion = this.questionCollection.enableOtherQuestionOfRepeated(smId, parentSectionId);
        if (numberOfEnableQuestion == 0) this.setRepeatValueToSurveyMapping(smId, false);

        //enable checkbox "Use as Interviewee"
        //if object is "Contact" and there is no repeated mapped question
        if ($('select.selectHeader[name="' + smId + '"]').val() == 'Contact' && numberOfEnableQuestion == 0){

            //enable the checkbox "Use as Interviewee"
            $('input.intervieweeCheckbox[name="' + smId + '"]').removeAttr('disabled');
        }
    },

    /**
     * This method set the repeat value (id of the parent repeated section) attached to the survey mapping.
     * Also set or remove the repeat message in order to show what repeat section is related to the survey mapping.
     * @param idSM Id of survey mapping.
     * @param idOfParentSection Id of the repeat Section.
     */
    setRepeatValueToSurveyMapping : function(idSM, idOfParentSection){
        var selectedMasterObject = _.find(this.masterObjectCollection.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == idSM; });
        if(isNotUndefined(selectedMasterObject)){
            if(idOfParentSection){
                var sectionCaption = this.sectionCollection.getCaptionById(idOfParentSection);
                $('.selectHeader[name="' + idSM + '"]').parent().attr('value', idOfParentSection);
                selectedMasterObject.set(REPEAT_ID_ATTR, idOfParentSection);
                this.setRepeatSection(idSM, sectionCaption);
            }
            else{
                $('.selectHeader[name="' + idSM + '"]').parent().removeAttr('value');
                selectedMasterObject.set(REPEAT_ID_ATTR, undefined);
                this.setRepeatSection(idSM, false);
            }
        } 
    },

    /**
     * Called when the object of a survey mapping changes, it enables all question mappings that were
     * disabled.
     * @param smId Id of the survey mapping changed.
     */
    enableQuestionMappings : function(smId){
        this.questionCollection.enableQuestionMappings(smId);
    },

    /**
     * Empty the list of survey mapping retrieved from the DB.
     */
    restartSurveyMappingIds : function(){
        this.firstSurveyMappings = [];
        this.usedFields          = {};
    },

    /**
     * Called when a survey mapping is deleted in order to made the proper changes to node relations
     * @param surveyIdToDelete Survey mapping recently deleted.
     */
    removeNodeRelation : function(surveyIdToDelete){
        this.nodeCollection.removeNodeRelation(surveyIdToDelete); // Removes the survey mapping from the list of nodes.
        this.refreshNodesParents();                               // Set the current parent relations.
    },

    /**
     * Restart node relations (parent-child relations).
     * This method must be called after we set masterObjectCollection of the page.
     */
    refreshNodesParents : function(){
        var self = this;
        this.nodeCollection.removeParentsOfNodes();               // Removes all parents in order to set them again.
        _.each(this.masterObjectCollection.models, function(mo){
           self.setParentsNodes(mo);
           if(isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).isInterviewee){
                // Here we set the special relations (checked contact and setted repondent in other object).
                var listMasterWithResponded = self.getListOfMasterObjectIdRespondedSetted();
                self.setChildrenOfContactInterviewee(mo.get(PARENT_OBJECT_ATTR).id, listMasterWithResponded);
           }        
        });
        this.nodeCollection.setAncestors();
        this.handleRepeatedVisibility();
        this.rerenderMasterObjects();
        this.refreshSpecialObjects();
    },

    /**
     *  Method in charge to obtain what repeatId each survey mapping has (because the survey mapping has, or because
     *  a parent has it), and with that id, disable (if necessary) the repeated sections that are different to the repeatId.
     */
    handleRepeatedVisibility : function(){
        var listOfSurveyMappings = retrieveSurveyMappings();
        var nodeList             = this.nodeCollection;
        var self                 = this;
        var listOfSmWithRepeat   = [];
        _.each(listOfSurveyMappings, function(sm){
            var nodeRelated       = nodeList.findNodeById(sm.get(ID_ATTR));
            // Obtain the repeat Id that this Survey mapping has, or its ancestors has.
            var repeatedIdForThis = nodeRelated.obtainRepeatIdOfAncestor(listOfSurveyMappings, nodeList);
            if(repeatedIdForThis != UNDEFINED_VALUE){
                nodeRelated.setRepeatIdForMeAndRelatives(repeatedIdForThis, nodeList, listOfSurveyMappings, listOfSmWithRepeat);
            }
            else{
                // No ancestor has a repeatId set.
                var isThisParentOfRepeated     = _.contains(listOfSmWithRepeat, sm.get(ID_ATTR));
                var listOfRepeatedMappingsOfSm = self.getListOfFieldsInRepeatedSections(sm.get(ID_ATTR));
                if(listOfRepeatedMappingsOfSm.length == 0 && !isThisParentOfRepeated){
                    // Doesn't have a mapping to a repeat and is not parent of a repeat so we enable repeats.
                    self.enableQMInRepeatedFromEvent(sm.get(ID_ATTR), repeatedIdForThis);
                    self.setRepeatValueToSurveyMapping(sm.get(ID_ATTR), false);
                }
            }
        });
        this.disableRelationsOfDifferentRepeated();
    },

    /**
     *  Method in charge to disable potential relations between object that are mapped to different repeat sections. 
     */
    disableRelationsOfDifferentRepeated : function(){
        // TODO : when merging with 2281 we must also disable contacts, and respondent (because of particular case).
        var self                 = this;
        var listOfSurveyMappings = retrieveSurveyMappings();
        self.masterObjectCollection.removeDisabledRelationsBecauseDiffRepeats();
        _.each(listOfSurveyMappings, function(sm){
            var currentRepeatId = (isNotUndefined(sm.get(REPEAT_ID_ATTR)) && sm.get(REPEAT_ID_ATTR) != '') ? sm.get(REPEAT_ID_ATTR) : UNDEFINED_VALUE;
            if(currentRepeatId != UNDEFINED_VALUE){
                // Has a repeatedId...
                _.each(listOfSurveyMappings, function(smCompared){
                    var comparedRepeatId = (isNotUndefined(smCompared.get(REPEAT_ID_ATTR)) && smCompared.get(REPEAT_ID_ATTR) != '') ? smCompared.get(REPEAT_ID_ATTR) : UNDEFINED_VALUE;
                    if(comparedRepeatId != UNDEFINED_VALUE && currentRepeatId != comparedRepeatId){
                        // Compared object and current object has repeatedId, and are different each other.
                        self.masterObjectCollection.disableRelationsBecauseDiffRepeats(sm.get(ID_ATTR), smCompared.get(ID_ATTR));
                    }
                });
            }
        });
    },

    /**
     * Called when retrieving survey mappings, returns true if the survey mapping with
     * the given Id has the respondent Submission Data (Interviewee) setted with any value.
     * @param smId Id of the survey mapping.
     * @return True if the respondent object is setted for the given Survey mapping Id.
     */
    hasRespondedSetted : function(smId){
        return this.questionSubmissionCollection.hasRespondedSetted(smId);
    },

    /**
     * Obtain list of master object id's(survey mapping related) that has respondent object setted.
     */
    getListOfMasterObjectIdRespondedSetted : function(){
        return this.masterObjectCollection.obtainMasterObjectsIdRespondentSetted();
    },

    /**
     * This method set the children (has responded setted) of the contact that has interviewee setted 
     * (is a relation Contact-otherObject) so we must consider that as a relation.
     * @param smId Id of the survey mapping with interviewee checked.
     * @param listOfChildren List of survey mappings that have respondent setted.
     */
    setChildrenOfContactInterviewee : function(smId, listOfChildren){
        this.nodeCollection.setParentsNodes(smId, listOfChildren);
    },

    /**
     *  Method in charge to disable respondents of the parents of checked contact and
     *  survey mappings that are in different repeats than the contact (if there is a checked contact).
     */
    disableRespondents : function(){
        var contactAsInterviewee = this.masterObjectCollection.getUseAsIntervieweeObject();
        if(isNotUndefined(contactAsInterviewee)){
            var listOfParents = this.nodeCollection.getParentsOfNode(contactAsInterviewee.get(PARENT_OBJECT_ATTR).id);
            // Disable respondents of parents of checked contact.
            this.questionSubmissionCollection.setDisableRespondents(listOfParents, contactAsInterviewee.get(PARENT_OBJECT_ATTR).id, DISABLE_SPECIAL_RELATION );
            if(isNotUndefined(contactAsInterviewee.get(REPEAT_ID_ATTR)) && contactAsInterviewee.get(REPEAT_ID_ATTR) != ''){
                // If the contact is mapped to repeat, disable respondent for survey mappings in different repeats (to avoid the relation).
                this.questionSubmissionCollection.setDisableRespondents(contactAsInterviewee.get(DISABLE_DIFF_REPEATS), contactAsInterviewee.get(PARENT_OBJECT_ATTR).id, DISABLE_SPECIAL_DIFF_REP );
            }
        }
    },

    /**
     *  Method in charge to enable all Interviewee checkboxes.
     */
    enableAllContactCheckbox : function(){
        var self = this;
        $('.intervieweeContainer:visible').each(function() {
            var currentContainer = $(this);
            self.enableUseAsIntervieweeStyles(currentContainer);
        });
    },

    /**
     *  Called when user set a field to a respondent, disable checkbox of contacts that are children of the survey 
     *  mapping related to the respondent set and those that are in different repeat section than the given 
     *  survey mapping Id.
     *  @param Survey mapping Id.
     */
    disableContactCheckbox : function(smId){
        var self                   = this;
        // Obtain repeatId from the respondent (if is set).
        var masterObjectRespondent = _.find(this.masterObjectCollection.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == smId; });
        var repeatOfRespondent     = (isNotUndefined(masterObjectRespondent) && isNotUndefined(masterObjectRespondent.get(REPEAT_ID_ATTR))) ? masterObjectRespondent.get(REPEAT_ID_ATTR) : '';
        $('.intervieweeContainer:visible').each(function() {
            // Is smId ancestor of the current contact?...
            var currentContainer            = $(this);
            var idContact                   = currentContainer.attr('name');
            var listParentsOfCurrentContact = self.nodeCollection.getParentsOfNode(idContact);
            var isAncestorOfContact         = _.contains(listParentsOfCurrentContact, smId);

            // Is repeatId from the contact different of smId repeat? (if is set).
            var masterObjectOfContact       = _.find(self.masterObjectCollection.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == idContact; });
            var repeatOfContact             = (isNotUndefined(masterObjectOfContact) && isNotUndefined(masterObjectOfContact.get(REPEAT_ID_ATTR))) ? masterObjectOfContact.get(REPEAT_ID_ATTR) : '';
            var isContactInDiffRepeatOfResp = repeatOfRespondent != '' && repeatOfContact != '' && repeatOfRespondent != repeatOfContact;
            
            if( smId != idContact && ( isAncestorOfContact || isContactInDiffRepeatOfResp ) ){
                // Is not the same id that I clicked (I can't be my own parent) and ...
                if(isAncestorOfContact){
                    // ... smId is ancestor of the current contact.
                    self.disableUseAsIntervieweeStyles(currentContainer, cannotCheckCircular); 
                }
                else if(isContactInDiffRepeatOfResp){
                    // ... current contact and smId are in different repeats.
                    self.disableUseAsIntervieweeStyles(currentContainer, cannotCheckBecauseDiffRepeats); 
                }
            }
        });
    },

    /** 
     *  Set the correct classes, title and attributes to disable checkbox "Use as interviewee".
     *  @param Element to be changed.
     *  @param messageToDisplay Message to be shown in the popup.
     */
    disableUseAsIntervieweeStyles : function(currentContainer, messageToDisplay){
        currentContainer.addClass('disableIntervieweeContainer');
        currentContainer.attr('title', messageToDisplay);
        currentContainer.find('input:checkbox').attr('disabled', 'disabled');
    },

    /** 
     *  Set the correct classes and attributes to enable checkbox "Use as interviewee".
     *  @param Element to be changed. 
     */
    enableUseAsIntervieweeStyles : function(currentContainer){
        currentContainer.removeClass('disableIntervieweeContainer');
        currentContainer.removeAttr('title');
        currentContainer.find('input:checkbox').removeAttr('disabled');
    },

    /**
     *  Method that disable "Use as interviewee" checkboxes for that contacts that could create circular dependency
     *  or are in different repeat sections of the survey mappings with repondent set.
     */
    disableUseAsInterviewee : function(listOfSurveyMappings){
        // Obtain list of survey mappings that have respondent set.
        var respondentQuestion     = this.questionSubmissionCollection.getElementById(RESPONDENT_ID);
        var listOfSMWithRespondent = _.filter(listOfSurveyMappings, function(sm){return respondentQuestion.hasRespondedSetted(sm.get(ID_ATTR)); });
        var self                   = this;
        _.each(listOfSMWithRespondent, function(smWRespId){
             self.disableContactCheckbox(smWRespId.get(ID_ATTR));
        });
    },

    /**
     *  Method in charge to refresh the list of respondents.
     *  First set all respondents to enabled, then disable only those that are set (if a contact is checked).
     *
     */
    refreshRespondents : function(){
        this.questionSubmissionCollection.enableAllRespondents();
        this.disableRespondents();
        var respondentQuestion = this.questionSubmissionCollection.getElementById(RESPONDENT_ID);
        respondentQuestion.rerender()
    },

    /**
     *  Method in charge to refresh the list of Interviewee checkboxes.
     */
    refreshIntervieweeCheckboxes : function(){
        this.enableAllContactCheckbox();
        var listSm = retrieveSurveyMappings();
        this.disableUseAsInterviewee(listSm);
    },

    /** 
     * Refresh the list of respondents and the list of checkbox to be enabled.
     * This method is called after th relations are set (including special relations).
     */
    refreshSpecialObjects : function(){
        this.refreshRespondents();
        this.refreshIntervieweeCheckboxes();
    },

    /**
     *  Called when the user change an object, here we set the field 'disable' to false.
     *  @param Id of the changed survey mapping.
     */
    enableRespondentOfSurveyMapping : function(smId){
        var respondentQuestion = this.questionSubmissionCollection.getElementById(RESPONDENT_ID);
        respondentQuestion.enableDirectDisable(smId);
    },

    /**
     * Construct the idField select combo of the given survey mapping id.
     * @param smId Survey mapping Id.
     * @param idCombo Combo element of the idField.
     */
    constructIdFieldCombo : function(smId, idCombo){
        // Obtain the list of field names that are in repeated sections.
        var listOfFieldInRepeatedSections = this.getListOfFieldsInRepeatedSections(smId);
        var currentSelectedText           = $(idCombo).find('option:selected').val();

        // Here we construct the idField select combo.
        idCombo.empty();
        idCombo[0].options[idCombo[0].options.length] = new Option(UNDEFINED_LABEL,UNDEFINED_VALUE);
        var selectedOptionArray = globalSelectedOptions.getSelectedOptionArray(smId).sort();
        for (var i = 0 ; i < selectedOptionArray.length; i++){
            if(selectedOptionArray[i][0] != UNDEFINED_VALUE) {
                if(listOfFieldInRepeatedSections.length == 0 || _.contains(listOfFieldInRepeatedSections, selectedOptionArray[i][0])){
                    // Because of 2190 issue if there is at least one repeated question mapped, we should construct the
                    // idField combo exclusively with fields of repeated questions (all fields otherwise).
                    // This is the filter in charge to allow all valid fields to be added to the idField combo
                    // (if no repeat question is mapped (listOfFieldInRepeatedSections.length == 0))  or
                    // allow only the fields that are valid and are mapped to repeated questions.
                    idCombo[0].options[idCombo[0].options.length] = new Option(selectedOptionArray[i][1],selectedOptionArray[i][0]);
                }
            }
        }
        // Check if the field that was selected is still in the idField combo.
        var isFormerSelectedFieldPresent = $(idCombo).find('option[value="' + currentSelectedText + '"]').length > 0;
        if(isFormerSelectedFieldPresent){
            // The field is still present so we set the field as selected.
            $(idCombo).find('option[value="'+currentSelectedText.replace(/\s+/g, ' ')+'"]').attr("selected","selected");
        }
        else{
            // The field is not present so we should change the idField of the master object too.
            this.setLabelIdField(smId, UNDEFINED_LABEL);
        }
    },

    /**
     * Called when a question mapping is changed in order to know what fields are related to repeated questions
     * and the given survey mapping.
     * @param Survey mapping.
     * @return List of name fields of repeated sections.
     */
    getListOfFieldsInRepeatedSections : function(smId){
        return this.questionCollection.getListOfFieldsInRepeatedSections(smId);
    },

    /**
     *  Called when the user click on done (popup of relations), obtain the list of removed fields from
     *  the list of relations for that objects.
     *  @param idChildObject Id of the child object in the relation.
     *  @param idParentObject Id of the parent object in the relation.
     *  @param savedRelations Relations set after click on done.
     */
    obtainRemovedFieldsForGivenObjects : function(idChildObject, idParentObject, savedRelations){
        var removedRelations = [];
        var usedFieldsOfChildObject = _.find(this.usedFields, function(uf, ufId){ return ufId == idChildObject; });
        // Obtain previously saved relations.
        if(isNotUndefined(usedFieldsOfChildObject)){
            var previouslySavedRelations = _.filter(usedFieldsOfChildObject , function(ufChild){ return ufChild.parentObjectId == idParentObject; });
        }
        // Obtain relations that were removed.
        _.each(previouslySavedRelations, function(prevRel){
            var objectJoin = _.find(savedRelations, function(savedRel){ return savedRel.name == prevRel.fieldName; });
            if(!isNotUndefined(objectJoin)){
                // Is not in the list of saved after click on "Done".
                removedRelations.push(prevRel);
            }
        });
        return removedRelations;
    },

    /**
     *  Obtain the fields that were removed when clicking in "Done", and removes the errors for that fields.
     *  This is done this way (instead of remove all errors and set new errors again) because the questions
     *  size could be a large number, and would be slow in that case.
     *  @param idChildSurveyMapping Child object Id.
     *  @param parentId Parent object Id.
     *  @param savedRelations Relations set after click on done.
     */
    removeErrorFieldsFromRelation : function(idChildSurveyMapping, parentId, savedRelations){
        // Obtain only those relations that were removed.
        var removedRelations = this.obtainRemovedFieldsForGivenObjects(idChildSurveyMapping, parentId, savedRelations);      
        // After found the removed relations, proceed to remove error on those fields that are not repeated anymore.
        _.each(removedRelations, function(removedRel){
            var questionsWithFieldSet        = fMPage.questionCollection.obtainFieldsInUse(idChildSurveyMapping, removedRel.fieldName);
            var specialQuestionsWithFieldSet = fMPage.questionSubmissionCollection.obtainFieldsInUse(idChildSurveyMapping, removedRel.fieldName);
            var joinedQuestions              = questionsWithFieldSet.concat(specialQuestionsWithFieldSet);
            if(_.size(joinedQuestions) == 1){
                // There is only one object marked as repeated so we remove the error...
                joinedQuestions[0].removeErrorForAnotherQuestion(removedRel.fieldName, idChildSurveyMapping);
            }
        });     
    },

	/**
     * Removes all fields for the given objects of the list of used fields. 
     * @param idChildObject Id of the child object in the relation.
     * @param idParentObject Id of the parent object in the relation.
     */
    removeUsedFieldsForGivenObjects : function(idChildObject, idParentObject){
        var usedFieldsOfChildObject = _.find(this.usedFields, function(uf, ufId){ return ufId == idChildObject; });
        if(isNotUndefined(usedFieldsOfChildObject)){
            this.usedFields[idChildObject] = _.filter(usedFieldsOfChildObject , function(ufChild){ return ufChild.parentObjectId != idParentObject; });
        }
    },

    /**
     *  Removes field of used fields for the given child object, and field name.
     *  @param idChildObject Id of the child object in the relation.
     *  @param parentId Id of the parent object (question object).
     *  @param fieldName Name of the field.
     */
    removeUsedFieldsForGivenChildAndField : function(idChildObject, parentId, fieldName){
        var usedFieldsOfChildObject = _.find(this.usedFields, function(uf, ufId){ return ufId == idChildObject; });
        if(isNotUndefined(usedFieldsOfChildObject)){
            var indexToRemove = UNDEFINED_VALUE;
            for(var i=0; i<usedFieldsOfChildObject.length; i++ ){
                var ufChild = usedFieldsOfChildObject[i];
                if(ufChild.fieldName == fieldName && ufChild.parentObjectId == parentId){
                    indexToRemove = i;
                    break;
                }
            }
            if(indexToRemove != UNDEFINED_VALUE){
                usedFieldsOfChildObject.splice(indexToRemove,1);
            }
        }   
    },

    /**
     * Adds the given data to the list of used fields.
     * @param usedFields Fields with the format: usedFields[childObjectId] = [{parentObjectId, fieldName}, ...]
     */
    addUsedFields : function(usedFields){
        var self = this;
        _.each(usedFields, function(uf, ufChildId){
            var listUsedFieldsSoFar = (isNotUndefined(self.usedFields[ufChildId])) ? self.usedFields[ufChildId] : [];
            _.each(uf, function(eachUsedField){
               listUsedFieldsSoFar.push(eachUsedField);
            });
            self.usedFields[ufChildId] = listUsedFieldsSoFar;
        });
    },

    /**
     * Called when the user removes a survey mapping, removes the map of the given children Id, and for other
     * children, removes the fields where the surveyIdToDelete is the parent.
     * Also removes the errors that would be removed if the relations related to that survey mapping were removed.
     * @param surveyIdToDelete Id of the recently removed survey mapping.
     */
    removeUsedFieldsOfSurveyMapping : function(surveyIdToDelete){
        var self = this;
        _.each(this.usedFields, function(ufMap, ufId){
            // First we should remove the errors (if there is errors) from the repeated questions mapping because this relation is removed.
            var relationsWhereIsParent = _.filter(ufMap , function(ufChild){ return ufChild.parentObjectId == surveyIdToDelete; });
            _.each(relationsWhereIsParent, function(relWhereParent){
                // All relations were removed, that's why we send an empty array as third parameter.
                self.removeErrorFieldsFromRelation(ufId, surveyIdToDelete, []);
            });         
            // Removes the used fields where the given Id is parent...
            self.usedFields[ufId] = _.filter(ufMap , function(ufChild){ return ufChild.parentObjectId != surveyIdToDelete; });
        });
        // Removes errors on question mappings related to surveyIdToDelete that had errors.
        this.questionCollection.removeErrorsOfQuestionMappings(surveyIdToDelete);
        this.questionSubmissionCollection.removeErrorsOfQuestionMappings(surveyIdToDelete);
        // and removes used fields surveyIdToDelete where  is child.
        this.usedFields[surveyIdToDelete] = [];
    },

    /**
     * Method in charge to remove the fields (master-detail) (that are treated as fields)
     * of the list of setted fields for the given survey mapping id.
     * To do that this method retrieve the setted fields of the master object, and look for that data
     * (masterObject.name, field.name) in the list of mandatory fields (relations treated as fields) in order
     * to remove them.
     * @param Survey mapping id to remove.
     */
     removeMasterDetailsRelationsAsFields : function(smToRemove){
        var mapObjectNameListFields = this.masterObjectCollection.obtainRelationsOfGivenId(smToRemove);
        _.each(mapObjectNameListFields, function(fieldsToRemove, childId){
            _.each(fieldsToRemove, function(fieldName){
                globalSelectedOptions.removeValue(childId, fieldName); 
            });
        });
     },

     /**
     * Collect data of the used fields, and put it in the proper format to be sent to the used fields 
     * of the page model.
     * @param mapUsedFields Object that will store the used fields for the child object.
     * @param childrenObjectId Id of the child object in the relation.
     * @param parentObjectId Id of the parent object in the relation.
     * @param fieldName Name of the field.
     */
    addFormatUsedField : function(mapUsedFields, childrenObjectId, parentObjectId, fieldName){
        var listOfUsedFieldsOfChild = (isNotUndefined(mapUsedFields[childrenObjectId])) ? mapUsedFields[childrenObjectId] : [];
        listOfUsedFieldsOfChild.push({parentObjectId : parentObjectId, fieldName : fieldName});
        mapUsedFields[childrenObjectId] = listOfUsedFieldsOfChild;
    },

    /**
     *  Returns true if the idField of the given survey mapping is mapped to a regular section. 
     *  @param Id of the survey mapping.
     *  @return True if the idField of the given survey mapping is mapped to a regular section, false otherwise.
     */
    isIdFieldInRegularSection : function(idChildSurveyMapping){
        var isIdInRegularQuestion = false;
        var nameIdField = $('.idFieldClass[name="' + idChildSurveyMapping + '"]').find('option:selected').attr('value');
        if(isNotUndefined(nameIdField) && nameIdField != UNDEFINED_VALUE ){
            // Has idField.
            var questStdWithGivenField  = this.questionCollection.obtainFieldsInUse(idChildSurveyMapping, nameIdField);
            var questSubmWithGivenField = this.questionSubmissionCollection.obtainFieldsInUse(idChildSurveyMapping, nameIdField);
            var questionsWithGivenField = questStdWithGivenField.concat(questSubmWithGivenField);
            var qRegularWithGivenField  = _.find(questionsWithGivenField, function(q){ return !q.get(BELONGS_REPEAT); });
            // If qRegularWithGivenField is found, it means that at least one not repeated question has the field assigned.
            isIdInRegularQuestion       = isNotUndefined(qRegularWithGivenField);
        }
        return isIdInRegularQuestion;
    },

    /**
     *  Removes the Id field of the given survey mapping.
     *  @param Survey mapping Id.
     */
    removeIdField : function(smId){
        $(".idFieldClass[name='" + smId + "']").attr('value', UNDEFINED_VALUE);
        this.setLabelIdField(smId, UNDEFINED_LABEL);
    },

    /**
     *  Method in charge to obtain what survey mappings are descendent of the given survey mapping Id and have 
     *  idField in a regular section.
     *  @param Id of the parent survey mapping.
     *  @return List of survey mappings that are descendent of the given survey mapping Id and have 
     *  idField in a regular section.
     */
    getDescendentsWithIdFieldInRegular : function(parentId){
        var self                 = this;
        var listOfDescendents    = [];
        var parentMasterObject   = _.find(this.masterObjectCollection.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && parentId == mo.get(PARENT_OBJECT_ATTR).id ; });
        if(isNotUndefined(parentMasterObject)){
            var listOfSurveyMappings = retrieveSurveyMappings();
            _.each(listOfSurveyMappings, function(sm){
                if(sm.get(ID_FIELD_LABEL) != UNDEFINED_LABEL && self.isIdFieldInRegularSection(sm.get(ID_ATTR))){              
                    // Has idField in a regular section...
                    var isSMDescendentOfParent = fMPage.nodeCollection.isAncestor(parentId, sm.get(ID_ATTR));
                    if(isSMDescendentOfParent){
                        // Survey mapping is descendent of parentId, so we add it to the list.
                        listOfDescendents.push(sm);
                    }
                }
            });
        }
        return listOfDescendents;
    },

    /**
     *  Method that validates that if a new id Field is set, and the field is mapped to a regular section, and any parent of
     *  {this} is mapped to a repeat section, the id Field should not be able to set. 
     *  @param Id of the survey mapping whose Id field is changing.
     *  @return True if the id Field is able to be set, false otherwise.
     */
    isAbleToSetIdField : function(childId){
        var isAbleToSetIdField = true;
        var self               = this; 
        var isIdFieldInRegular = fMPage.isIdFieldInRegularSection(childId);
        if(isIdFieldInRegular){
            // Obtain master objects that are ancestors of the childId and mapped to repeat sections.
            var listOfSmRepeatsParents  = _.find(this.masterObjectCollection.models, function(mo){
                                                    return isNotUndefined(mo.get(REPEAT_ID_ATTR))   // Has RepeatId attribute.
                                                    && isNotUndefined(mo.get(PARENT_OBJECT_ATTR))   // Has parent object
                                                    && self.nodeCollection.isAncestor(mo.get(PARENT_OBJECT_ATTR).id, childId); // Is ancestor of childId.
                                          });
            isAbleToSetIdField          = !isNotUndefined(listOfSmRepeatsParents);
        }
        return isAbleToSetIdField;
    },

    /**
     *  Method in charge to display in what repeat section the survey mapping is associated
     *  (or remove the message if sectionCaption is false).
     *  @param smId Survey mapping Id.
     *  @param sectionCaption Caption of the selected survey, or false if want to remove the message
     */
    setRepeatSection : function(smId, sectionCaption){
        if(sectionCaption){
            sectionCaption = htmlEncode(sectionCaption);
            if($('.selectHeader[name="' + smId + '"] ~ .repeatMessage').length == 0) $('.selectHeader[name="' + smId + '"] ~ span').after('<div class="repeatMessage" > ' + repeatsToMessage + ' ' + sectionCaption + '</div>'); 
        }
        else{
            if($('.selectHeader[name="' + smId + '"] ~ .repeatMessage').length > 0) $('.selectHeader[name="' + smId + '"] ~ .repeatMessage').remove();
        }
    }
});



//-------------------------End Page model-----------------------------




//-----------------------------Views-----------------------------

/*
*    Parent of question and section views.
*/
var AbstractQuestionRowViewFM = Backbone.View.extend({

    tagName: "tr",

    events: {

    },

    render: function() {

    }

});

/*
*    View of a section.
*/
var SectionRowViewFM = AbstractQuestionRowViewFM.extend({

    initialize : function() {
        _.bindAll(this, 'render');
        this.model.on("change:childrenSize", this.render, this);
    },

    events: {

    },

    className: "tertiaryPalette readonly section",

    render: function() {
        var self = this;
        var myTemplate = _.template($('#sectionFM-template').html());
        var surveyMappingFields = this.model.get('childrenSize');
        $(this.el).html(myTemplate({
            caption       : self.model.get(CAPTION_ATTRIBUTE),
            typeOfSection : self.model.get(SECTION_ATTR),
            columnsLength : surveyMappingFields,
            sectionHeader : self.model.get(NUMBER_HEADER_ATTR)
        }));
        return $(this.el);
    }

});

/*
*    View of a question.
*/
var QuestionRowViewFM = AbstractQuestionRowViewFM.extend({

    initialize : function() {
        _.bindAll(this, 'render');
        this.model.on("change:childrenMappedFields", this.render, this);
    },

    events: {
        "change .childSelect"      : "updateQuestionChanged",
        "focus .childSelect"       : "updateOldQuestionChanged"
    },

    className: "question",

    render: function() {
        var self             = this;
        var myTemplate       = _.template($('#questionFM-template').html());
        var comboChildren    = this.model.get(CHILDREN_ATTR);
        var childrenLength   = (typeof comboChildren == 'undefined') ? 0 : comboChildren.length;
        var belongsRepeat    = this.model.get(BELONGS_REPEAT); // Patch to avoid ANY repeat question to be mapped.
        $(this.el).html(myTemplate({
            caption               : self.model.get(CAPTION_ATTRIBUTE),
            questionRequired      : self.model.get(REQUIRED_ATTR),
            listOfChildren        : comboChildren,
            totalChildren         : childrenLength,
            typeOfQuestion        : self.model.get('type'),
            questionHeader        : self.model.get(NUMBER_HEADER_ATTR),
            belongsRepeat         : belongsRepeat
        }));
        return $(this.el);
    },

    /**
    *    Method triggered when a user clicks on a question mapping.
    */
    updateQuestionChanged : function(e){

        hasUnsavedChanges        = true;
        var comboSelected        = $(e.currentTarget).find('option:selected');
        var nameFieldSelected    = comboSelected.attr('value');
        var headerRelated        = comboSelected.attr('name');
        var selectedCaption      = comboSelected.html();
        var idCombo              = $(".idFieldClass[name='"+headerRelated+"']");
        var didSelectField       = (nameFieldSelected != UNDEFINED_VALUE); // True if is selecting a new field, false if is selecting none.
        var acceptsChanges       = true; // False if the user doesn't want to remove current idField, true otherwise.
        var acceptChildIdField   = true; // False if the user doesn't want to unset the id field of some ancestor with if field in a regular, true otherwise.
        var acceptChildIdSpecial = true; // False if user doesn't want to remove Id fields after a particular case is set (IDALMSA-2699), true otherwise.

        if(this.model.get(ID_ATTRIBUTE) == RESPONDENT_ID && didSelectField){
            // Is respondent and has a field selected.
            // Here we make sure that me and my descendents will remove its Id fields (if are in regular sections) 
            // if parent has repeat set(when relating (particular case) two objects) (IDALMSA-2699).
            var contactAsInterviewee = fMPage.masterObjectCollection.getUseAsIntervieweeObject();
            if(isNotUndefined(contactAsInterviewee) && isNotUndefined(contactAsInterviewee.get(REPEAT_ID_ATTR)) && contactAsInterviewee.get(REPEAT_ID_ATTR) != ''){
                // There is a contact checked and has repeat Id set.
                var isMyIdFieldInRegular     = fMPage.isIdFieldInRegularSection(headerRelated);
                var listDescIdFieldInRegular = fMPage.getDescendentsWithIdFieldInRegular(headerRelated);
                if(isMyIdFieldInRegular || listDescIdFieldInRegular.length > 0){
                    // Either {this} has Id field in a regular section, or a descendent has.
                    acceptChildIdSpecial = confirm(setRepondentWillUnsetIdField);
                    if(acceptChildIdSpecial){
                        // Will remove Id fields of this object and/or its descendants.
                        if(isMyIdFieldInRegular){ 
                            fMPage.removeIdField(headerRelated);
                        }
                        _.each(listDescIdFieldInRegular, function(descSmP){
                            fMPage.removeIdField(descSmP.get(ID_ATTR));
                        });
                    }
                }
            }
        }
        else if(this.model.get(BELONGS_REPEAT)){
            // Is a question inside a repeat section.
            var listOfFieldInRepeatedSections = fMPage.getListOfFieldsInRepeatedSections(headerRelated);
            var idFieldIsNotUndefined         = idCombo.find('option:selected').attr('value') != UNDEFINED_VALUE;

            if(listOfFieldInRepeatedSections.length == 0 && didSelectField && idFieldIsNotUndefined){
                // Enter here, so is setting a value of the first question mapping selected of a repeated question
                // (the idField is selected, so it will be removed, so we inform the user of this).
                acceptsChanges = confirm(thisWillRemoveIdFieldLabel);
            }
            if(acceptsChanges){
                // Either there was no need to ask if the idField will change, or the user accept to remove idField of this.
                // Here we find out if should disable Id field of a descendent because of 2459 issue.
                if(didSelectField){
                    var listDescIdFieldInRegular = fMPage.getDescendentsWithIdFieldInRegular(headerRelated);
                    if(listDescIdFieldInRegular.length > 0){
                        acceptChildIdField = confirm(mappingRepeatWillUnsetDescendents);
                        if(acceptChildIdField){
                            _.each(listDescIdFieldInRegular, function(descSm){
                                fMPage.removeIdField(descSm.get(ID_ATTR));
                            });
                        }
                    }
                }
            }
        }

        if(acceptsChanges && acceptChildIdField && acceptChildIdSpecial){
            // Enter here so either the user accepts to remove the id Field, or did not was necessary to ask.
            // If enters here the changes will be done.
            var sizeAlreadySelected   = globalSelectedOptions.isFieldAlreadySelected(headerRelated, nameFieldSelected); // Here we know if is another field selected for that survey mapping.
            var selectedCombo         = _.find(this.model.get(CHILDREN_ATTR), function(childMapp){ return childMapp.get(RELATED_COMBO_ATTR) == headerRelated; });
            selectedCombo.set(CHILDREN_REPEAT_ATTR, false);

            this.model.setFieldSelected(nameFieldSelected, headerRelated);
            globalSelectedOptions.setValue( headerRelated,this.model.get('Id'),nameFieldSelected,selectedCaption);

            this.removeUnneededErrors(headerRelated, this.previousElement.attr('value'));            
            // If is a repeat question enable or disable rest of repeated questions.
            if(this.model.get(BELONGS_REPEAT)) this.processQuestionMappingsRepeats(didSelectField, headerRelated, this.model.get(PARENT_ATTR) );
            // Handle if should enable or disable fields in the master objects.
            this.handleUsedFieldsFromQuestion(didSelectField, headerRelated, nameFieldSelected);
            // Recreate the idField select combo.
            fMPage.constructIdFieldCombo(headerRelated, idCombo);

            if(sizeAlreadySelected) {
                var questionsWithRepeatedFields = fMPage.getQuestionsOfRepeatedFields(headerRelated, nameFieldSelected);
                fMPage.setRepeatedValuesForCollection(headerRelated, nameFieldSelected, questionsWithRepeatedFields);
            }
            fMPage.refreshNodesParents();
        }
        if(this.model.get(ID_ATTRIBUTE) == RESPONDENT_ID){
            // Changed the respondent so we must refresh the master object (change hasRespondent attribute).
            fMPage.masterObjectCollection.setRespondentAttribute(nameFieldSelected == UNDEFINED_VALUE, headerRelated);
        }
        fMPage.refreshNodesParents();
        this.render();
    },

    /**
     *  Method in charge to enable or disable fields in master objects depending on what fields I set on
     *  question mappings.
     *  It adds the field selected (or removes) to the list of used fields.
     *  @param didSelectField True if the user select a field, false if let the question mapping empty.
     *  @param smId Survey mapping Id.
     *  @param fieldName Name of the field.
     */
    handleUsedFieldsFromQuestion : function(didSelectField, smId, fieldName){
        if(didSelectField){
            // Selected a field, so we add it to the list of used fields.
            var dummyUsedFields = {};
            dummyUsedFields[smId] = [{parentObjectId : this.model.get(ID_ATTRIBUTE), fieldName : fieldName}];
            fMPage.addUsedFields(dummyUsedFields);
        }
        else{
            // Deselect the combo, so we remove it from the list of used fields.       
            var nameFieldPreviousSelected = this.previousElement.attr('value');
            var sizeAlreadySelected   = globalSelectedOptions.isFieldAlreadySelected(smId, nameFieldPreviousSelected);
            fMPage.removeUsedFieldsForGivenChildAndField(smId, this.model.get(ID_ATTRIBUTE), nameFieldPreviousSelected);         
        }
        fMPage.masterObjectCollection.rerenderRelations();
    },

    /**
     * Method in charge to enable or disable question mappings of other repeated questions.
     * @param didSelectField False if is letting the question mapping empty, true otherwise.
     * @param smId Survey mapping Id.
     * @param parentSectionId Id of the parent of the question (this).
     */
    processQuestionMappingsRepeats : function(didSelectField, smId, parentSectionId){
        if(didSelectField){
            fMPage.disableQMInRepeatedFromEvent(smId, parentSectionId);
        }
        else{
            fMPage.enableQMInRepeatedFromEvent(smId, parentSectionId);
        }
    },

    /*
    *    Remove error messages from duplicates names triggered from current changed select.
    *    @param headerRelated Survey mapping Id.
    *    @param nameFieldPreviousSelected Name of the field previously selected.
    */
    removeUnneededErrors : function(headerRelated, nameFieldPreviousSelected){
        var sizeAlreadySelectedPrevious   = globalSelectedOptions.isFieldAlreadySelected(headerRelated, nameFieldPreviousSelected); // Here we know if is another field selected for that survey mapping.
        if(sizeAlreadySelectedPrevious == 1){
            fMPage.setFieldsWithoutError(headerRelated, nameFieldPreviousSelected);
        }
    },

    /*
    *    Set the previous value of the combo when change.
    */
    updateOldQuestionChanged : function(e){
        this.previousElement = $(e.currentTarget).find('option:selected');
    }

});

/*
*    Master object view.
*/
var MasterObjectRowViewFM = Backbone.View.extend({

    tagName: "tr",

    className: "masterObjectRow",

    initialize : function() {
        _.bindAll(this, 'render');
        this.model.on("change:objectRelationsMapping", this.render, this);
    },

    events: {
        "click .addRelationFields"       : "addRelationField",
        "click .cancelAddRelationFields" : "cancelAddRelation",
        "click .setRelationAnchor"       : "showRelationContainer",
        "click .setRelationAnchorChange" : "showRelationContainer"
    },

    render: function() {
        var self              = this;
        var currentNode       = _.find(fMPage.nodeCollection.models, function(node){ return node.get(ID_ATTR) == self.model.get(PARENT_OBJECT_ATTR).id; });
        var childrenRelations = (isNotUndefined(this.model.get(CHILDREN_RELATIONS))) ? this.model.getMapOfRelatedFields() : {};
        var surveyMappingList = this.model.get(POSSIBLE_MAPPINGS);
        var surveyMappingSize = surveyMappingList.length;
        var relatedFields     = this.model.get(OBJECT_RELATIONS_MAPPINGS);
        var parentNodes       = (typeof currentNode != 'undefined') ? currentNode.get(PARENTS_ATTR) : [];
        var myTemplate        = _.template($('#masterObjectFM-template').html());
        $(this.el).html(myTemplate({
            surveyMappingSize : surveyMappingSize,
            surveyMappingList : surveyMappingList,
            childrenRelations : childrenRelations,
            selectedParent    : self.model.get(PARENT_OBJECT_ATTR),
            relatedFields     : relatedFields,
            parentNodes       : parentNodes,
            usedFields        : fMPage.usedFields,
            differentRepeats  : self.model.get(DISABLE_DIFF_REPEATS)
        }));
        return $(this.el);
    },

    /**
    *   Called when adding new object relations.
    */
    addRelationField : function(e){
        hasUnsavedChanges        = true;
        var self                 = this;
        var fieldsContainer      = $(e.target).parent().parent();
        var idChildSurveyMapping = fieldsContainer.attr('name');
        var fieldTr              = $(fieldsContainer).find('.relationsFieldsTable tr');
        var listRelatedFields    = [];
        var dummyUsedFields      = {};
        var childObject          = _.find(fMPage.masterObjectCollection.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == idChildSurveyMapping; });
        var isParentInRepeat     = isNotUndefined(this.model.get(REPEAT_ID_ATTR)) || isNotUndefined(childObject.get(REPEAT_ID_ATTR));
        var isChildIdInRegular   = fMPage.isIdFieldInRegularSection(idChildSurveyMapping);
        var checkboxCheckedSize  = fieldsContainer.find('.checkboxRelatedField:checked').length;
        var acceptUnsetIdField   = true; // False if the user in not ok to unset current idField (if necessary), true otherwise.
        var descInRegularOfChild = fMPage.getDescendentsWithIdFieldInRegular(idChildSurveyMapping);
        var descInRegOfParent    = fMPage.getDescendentsWithIdFieldInRegular(this.model.get(PARENT_OBJECT_ATTR).id);

        if( isParentInRepeat                             // The parent or child of the relation is mapped to a repeat section.
            && checkboxCheckedSize > 0                   // The relation has been set (at least one field is been related).
                && ( isChildIdInRegular                  // Child object has Id Field in a regular section or...
                     || descInRegularOfChild.length > 0  // child object has at least one descendent with Id Field in a regular section or...
                     || descInRegOfParent.length > 0) ){ // parent object has at least one descendent with Id Field in a regular section.
            acceptUnsetIdField = confirm(setRelationWillUnsetIdField);
            if(acceptUnsetIdField) {
                // User accepts to unset the idFields of descendants, so we unset correct Id fields.
                if(isChildIdInRegular) fMPage.removeIdField(idChildSurveyMapping);
                _.each(descInRegularOfChild, function(descSm){
                    fMPage.removeIdField(descSm.get(ID_ATTR));
                });
                _.each(descInRegOfParent, function(descSmP){
                    fMPage.removeIdField(descSmP.get(ID_ATTR));
                });
            }
        }

        if(acceptUnsetIdField){
            // Either the user didn' have to unset the current idField, or was ok to unset Id field, so we allow the assign of relation.
            fieldTr.each(function(index) {
                // If the field is master-detail relation, removes it from the list of fields selected 
                // (is a relation that behaves like a field).
                var isMasterRelation = $.trim($(this).find('.spanRelationType').html()) == MASTER_DETAIL_RELATION;
                if(isMasterRelation){
                    var fieldName = $(this).find('.spanRelatedField').attr('name');
                    globalSelectedOptions.removeValue(idChildSurveyMapping, fieldName); 
                } 

                if($(this).find('.checkboxRelatedField:checked').length > 0){
                    // If the checkbox is checked, collect field data.
                    var dummyRelatedField      = {};
                    dummyRelatedField.name     = $(this).find('.spanRelatedField').attr('name');
                    dummyRelatedField.label    = $.trim($(this).find('.spanRelatedField').html());
                    dummyRelatedField.relation = $.trim($(this).find('.spanRelationType').html());
                    listRelatedFields.push(dummyRelatedField);

                    // Add the field to the list of used fields.
                    fMPage.addFormatUsedField(dummyUsedFields, idChildSurveyMapping, self.model.get(PARENT_OBJECT_ATTR).id, dummyRelatedField.name);
                    if(dummyRelatedField.relation == MASTER_DETAIL_RELATION){
                        // Set the relation field as a mapped field.
                        globalSelectedOptions.setValue(idChildSurveyMapping, dummyRelatedField.name, dummyRelatedField.name, dummyRelatedField.label);
                    }
                }
            });
            this.model.setRelatedFieldNames(idChildSurveyMapping, listRelatedFields);
            // Remove errors from relations that are not repeated anymore.    
            fMPage.removeErrorFieldsFromRelation(idChildSurveyMapping, self.model.get(PARENT_OBJECT_ATTR).id, listRelatedFields);
            // Remove all used fields of the given child and parent object, and add the recently collected.
            fMPage.removeUsedFieldsForGivenObjects(idChildSurveyMapping, self.model.get(PARENT_OBJECT_ATTR).id);
            fMPage.addUsedFields(dummyUsedFields);
            fMPage.refreshNodesParents();

            $(document).unbind('keyup');
            $('#block').hide();
        }
        else{
            this.cancelAddRelation();
        }

    },

    

    /**
    *   Called when cancelling adding a new object relation.
    */
    cancelAddRelation : function(){
        $(document).unbind('keyup');
        $('#block').hide();
        this.render();
    },

    /**
    *   Display the popup to select object relations.
    */
    showRelationContainer : function(e){
        //set width and heigth dinamically to match the current size of the html body
        $('#block').css({"height": $(document).height(),"width": $(document).width()});
        $('#block').show();
        var self = this;

        // bind on keyup event to catch when user hits escape key
        $(document).keyup(function(e){
            if(e.keyCode == 27){ // in case the user hits the escape key
                $(document).unbind('keyup'); //unbind the keyup event from document so is not triggered again
                self.cancelAddRelation(); // call the cancel button programaticly
            }
        });

        var anchorSetRel = e.target;
        $(anchorSetRel).parent().find('.relatedFieldsContainer').show();
    }

});


//---------------------------COLLECTIONS-------------------


var QuestionList = Backbone.Collection.extend({

    getElementById : function(id){
        return _.find(this.models ,function(e){return e.get('Id') == id;})
    },

    createEmptyColumns : function(selectNumber, idSurvey){
        var nameToRelate = (idSurvey) ? idSurvey : 'sc' + selectNumber;
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.createEmptyColumn(nameToRelate);
            });
        }
    },

    /**
    *    Populates childrenMappedFields data for all questions.
    */
    completeComboFromObject : function(fieldList, currentSelectedComboValue, currentSelectedCombo, listQuestionMapped, idFieldSelected){
      if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.setFieldsToCombo(currentSelectedCombo , fieldList, currentSelectedComboValue, listQuestionMapped, idFieldSelected);
            });
        }
        mapObjectIdToRequiredFields[currentSelectedCombo] = _.filter(fieldList, function(e){return e.required && ((( e.relatedTo != null && isNotUndefined(_.find(e.relatedTo, function(rf){ return rf.name == SURVEY_NAME; }))
                                                                                                                  || e.relatedTo != null && isNotUndefined(_.find(e.relatedTo, function(rf){ return rf.name == CONTACT_NAME; }))
                                                                                                                  || e.relatedTo != null && isNotUndefined(_.find(e.relatedTo, function(rf){ return rf.name == SURVEY_SUBMISSION_NAME; }))
                                                                                                                  || e.relatedTo != null && isNotUndefined(_.find(e.relatedTo, function(rf){ return rf.name == SURVEY_VERSION_NAME; })) )
                                                                                                                  || (e.type != "DATETIME" && e.type != "ID" && e.type != "BOOLEAN" && e.type!="REFERENCE")))});
        // Search for fields that are master objects in order to add them to the list of required
        _.each(fieldList, function(field){
            var isFieldInListRequired = isNotUndefined(_.find(mapObjectIdToRequiredFields[currentSelectedCombo], function(requiredField){ return requiredField.name == field.name; }));
            if(!isFieldInListRequired && field.relatedTo){
                _.each(field.relatedTo, function(parentObject){
                    if(parentObject.relationType == MASTER_DETAIL_RELATION){
                        mapObjectIdToRequiredFields[currentSelectedCombo].push(field);
                    }
                });
            }
        });
    },

    /**
    *    Obtain childrenMappedField of all questions.
    */
    getDataFromQuestionsChildren : function(){
        var arrayMappedQuestions =[];
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                if(quest.get(MODIFIED_ATTR)){
                    arrayMappedQuestions.push(quest.getMappedFields());
                }
            });
        }
        return arrayMappedQuestions;
    },

    /**
    *    Relate question mapping, survey mapping, and survey submissions in order to make easier to save them in server side.
    *    @param surveyMapping Data of survey mappings.
    *    @param arrayMappedQuestions Data of question mappings.
    *    @param arraySpecialQuestion Data of survey mappings special fields (surveyor, intervieww etc).
    */
    relateQuestionAndSurveyMapping : function(surveyMapping, arrayMappedQuestions, arraySpecialQuestion){
        var jsonToSend     = [];
        var self           = this
        _.each(surveyMapping, function(surveyMap){
                var classRelated                = surveyMap.smClassSelected;
                var arrayOfSurveySubmissions    = new Array();
                _.each(arraySpecialQuestion, function(specialQ){ arrayOfSurveySubmissions.push(specialQ[classRelated]); });
                var arrayOfCompleteData         = [];
                _.each(arrayMappedQuestions, function(questionArray){
                    var questionMap = _.filter(questionArray, function(questMap){ return questMap.relatedHeaderCombo == classRelated });
                    if(questionMap.length > 0) arrayOfCompleteData.push(questionMap[0]);
                });
                var surveyData = {};
                surveyData                  = self.getFixedValuesForSurveyMapping(arrayOfSurveySubmissions, surveyData);
                surveyData.classSelected    = surveyMap.smClassSelected;
                surveyData.objectMapped     = surveyMap.smObjectMapped;
                surveyData.surveyId         = surveyMap.surveyId;
                surveyData.questionMapping  = arrayOfCompleteData;
                surveyData.matchingField    = surveyMap.matchingField;
                surveyData.isInterviewee    = surveyMap.isIntervieww;
                surveyData.oldMapping       = surveyMap.oldMapping;
                surveyData.repeatIdSection  = surveyMap.repeatIdSection;
                surveyData.objectRelation   = surveyMap.objectRelation;
                jsonToSend.push(surveyData);
        });
        return jsonToSend;
    },

    /**
    *    Method in charge to put survey mappings to attributes in the server.
    *    @param arrayOfSurveySubmissions Values of survey submissions.
    *    @param surveyData Data of survey.
    */
    getFixedValuesForSurveyMapping : function(arrayOfSurveySubmissions, surveyData){
        _.each(arrayOfSurveySubmissions, function(surveySubm){
            if(isNotUndefined(surveySubm)){
                var surveySubmissionAttribute = '';
                switch(surveySubm.submissionName)
                {
                case 0    : surveySubmissionAttribute = 'SurveyVersion'; break;
                case 1    : surveySubmissionAttribute = 'Submission'; break;
                case 2    : surveySubmissionAttribute = 'Surveyor'; break;
                case 3    : surveySubmissionAttribute = 'Interviewee'; break;
                case 4    : surveySubmissionAttribute = 'PPIScore'; break;
                case 6    : surveySubmissionAttribute = 'Survey'; break;
                }
                surveyData[surveySubmissionAttribute] = surveySubm.mappedFieldName ;
            }
        });
        return surveyData;
    },

    /**
    *    Rerender all questions.
    */
    rerenderQuestions : function(){
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.rerender();
            });
        }
    },

    /**
    *    Removes all children of the questions.
    */
    removeAllChildren : function(){
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.removeChildren();
            });
        }
    },

    /**
    *    This method removes error of repeated fields for a given survey mapping.
    *    @param fieldSelected Selected field
    *    @param idSurveyMap Id of the survey mapping.
    */
    setFieldsUnselectedForSM : function(fieldSelected, idSurveyMap){
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.removeErrorForAnotherQuestion(fieldSelected, idSurveyMap);
            });
        }
    },

    /**
    *    Given a Survey mapping Id, removes all question mappings related to that survey mapping.
    *    @param Survey mapping Id.
    */
    removeColumnFromId : function(idSurveyMap){
        if(this.models.length > 0){
            _.each(this.models, function(quest){
                quest.removeChildrenFromSMId(idSurveyMap);
            });
        }
    },

    /**
     * Return the list of questions that are mapped to the given field name in the given survey mapping.
     * This is used for detecting duplicate mappings to the same object and field.
     * @param surveyMappingId Id of the Survey mapping
     * @param fieldAPIName Name selected
     * @return List of questions.
     */
    obtainFieldsInUse : function(surveyMappingId, fieldAPIName){
        return _.filter(this.models, function(q){ return q.hasFieldInUse(surveyMappingId, fieldAPIName); });
    },

    /**
     * Method in charge to disable questions mappings (of the given survey mappings) of repeated sections.
     * @param Id's of survey mappings retrieved from DB.
     */
    disableQMOfRepeated : function(smIdList){
        // Obtain questions that belongs to a repeated section.
        var questionOfRepSections = _.filter(this.models, function(q){ return q.get(BELONGS_REPEAT); });
        var self                  = this;
        _.each(smIdList, function(idSM){
            // Iterate over survey mappings id, in order to see what questions of repeated sections has the question mapping setted.
            var questOfRepeatedWithValueOfSM = _.find(questionOfRepSections, function(qOfR){ return qOfR.hasQMSetted(idSM); });
            if(isNotUndefined(questOfRepeatedWithValueOfSM)){
                // For this SM id, there is at least one repeated question, that has a question mapping related to the survey mapping.
                fMPage.setRepeatValueToSurveyMapping(idSM, questOfRepeatedWithValueOfSM.get(PARENT_ATTR));
                self.disableOtherQuestionOfRepeated(idSM, questionOfRepSections, questOfRepeatedWithValueOfSM.get(PARENT_ATTR));
            }
        });
    },

    /**
     * Method in charge to disable all questions mappings (of the selected survey mapping) of questions
     * (that belongs to a repeated section) except for those that belongs to the same section.
     * @param smId Id of the survey mapping.
     * @param questionOfRepSections List of questions that has a repeated section parent.
     * @param parentOfSelectedQuestion Section Id of the parent of the question with a question mapping in it (in order
     * to not disable it).
     */
    disableOtherQuestionOfRepeated : function(smId, questionOfRepSections, parentOfSelectedQuestion){
        var listRepQuestNotInSameSection = _.filter(questionOfRepSections, function(q){ return q.get(PARENT_ATTR) != parentOfSelectedQuestion; });
        _.each(listRepQuestNotInSameSection, function(qToDisable){
            qToDisable.setQuestionMappingVisibility(smId, true);
        });
    },

    /**
     * Method in charge to enable all questions mappings (of the selected survey mapping) of questions
     * (that belongs to a repeated section).
     * @param smId Id of the survey mapping.
     * @param parentOfSelectedQuestion Section Id of the parent of the question.
     */
    enableOtherQuestionOfRepeated : function(smId, parentSectionId){
        var listQuestInSameSectionMappedToSM = _.filter(this.models, function(q){ return q.get(PARENT_ATTR) == parentSectionId && q.hasQMSetted(smId); });
        var self                             = this;
        if(listQuestInSameSectionMappedToSM.length == 0){
            var listQuestionInRepeatedSections = _.filter(self.models, function(q){ return q.get(BELONGS_REPEAT); });
            _.each(listQuestionInRepeatedSections, function(qToEnable){
                qToEnable.setQuestionMappingVisibility(smId, false);
            });
            fMPage.setRepeatValueToSurveyMapping(smId, false);
        }

        return listQuestInSameSectionMappedToSM.length;
    },

    /**
     * When a survey mapping changes its object, it should let all question mapping (of repeated questions) of that
     * survey mapping enabled.
     * @param smId Id of the survey mapping changed.
     */
    enableQuestionMappings : function(smId){
        var questionOfRepSections = _.filter(this.models, function(q){ return q.get(BELONGS_REPEAT); });
        _.each(questionOfRepSections, function(q){
             q.setQuestionMappingVisibility(smId, false);
        });
    },

    /**
     * Obtain the list of field names that belong to repeated sections and are related to the given Id.
     * @param Survey mapping Id.
     * @return Array with names of fields.
     */
    getListOfFieldsInRepeatedSections : function(smId){
        var listOfFieldNames = [];
        var questionOfRepSections = _.filter(this.models, function(q){ return q.get(BELONGS_REPEAT); });
        _.each(questionOfRepSections, function(q){
             var fieldName = q.getFieldRelatedOfSurveyMapping(smId);
             if(fieldName != UNDEFINED_VALUE) listOfFieldNames.push(fieldName);
        });
        return listOfFieldNames;
    },

    /**
     *  Method in charge to remove errors in all question mappings for a given survey mapping.
     *  @param smId Survey mapping Id. 
     */
    removeErrorsOfQuestionMappings : function(smId){
        var questionWithErrorsOnGivenSurveyMapping = _.filter(this.models, function(q){ return isNotUndefined(q.getComboRelated(smId)) && q.getComboRelated(smId).get(CHILDREN_REPEAT_ATTR); });
        _.each(questionWithErrorsOnGivenSurveyMapping, function(question){
            question.removeErrorOnQuestionMapping(smId)
        }); 
    },

    /**
     * Looks for respondent question, and checks if for the given Id, the question mapping is setted.
     * @param smId Id of the survey mapping.
     * @return True if the respondent object is mapped for the given Id.
     */
    hasRespondedSetted : function(smId){
        var isRespondentSetted        = false;
        var respondentSpecialQuestion = this.getElementById(RESPONDENT_ID);
        if(isNotUndefined(respondentSpecialQuestion)){
            isRespondentSetted = respondentSpecialQuestion.hasRespondedSetted(smId);
        }
        return isRespondentSetted;
    },

    /**
     * Method that set the attribute disableChildContact as true (for each id of the given list)
     * in order to disable respondent fields that could create a circular dependency, or are in different repeats.
     * @param listOfNewParentsOfContact List of parents of the contact that is interviewee.
     * @param contactId Id of the checked contact (in order to avoid set the contact as disable because of contact).
     * @param disableAttribute Disable attribute that will be set to true (i.e. disable because are in
     * different repeats (DISABLE_SPECIAL_DIFF_REP), or because would create a circular dependency (DISABLE_SPECIAL_RELATION)).
     */
    setDisableRespondents : function(listOfNewParentsOfContact, contactId, disableAttribute){
        var respondentSpecialQuestion = this.getElementById(RESPONDENT_ID);
        if(isNotUndefined(respondentSpecialQuestion)){
            respondentSpecialQuestion.setDisabledBecauseContact(listOfNewParentsOfContact, contactId, disableAttribute);
        }
    },

    /**
     *  Enable all question mappings of the repondent question (set attribute DISABLE_SPECIAL_RELATION and DISABLE_SPECIAL_DIFF_REP to false).
     */
    enableAllRespondents : function(){
        var respondentSpecialQuestion = this.getElementById(RESPONDENT_ID);
        if(isNotUndefined(respondentSpecialQuestion)){
            respondentSpecialQuestion.setAllRespondentEnabled();
        }
    }

});

var SectionList = Backbone.Collection.extend({

    rerenderAllSections : function(sizeOfChildren){
        if(this.models.length > 0){
            _.each(this.models, function(section){
                section.setChildrenSize(sizeOfChildren);
            });
        }
    },

    /**
     *  Method that given a section Id, returns the caption of that section.
     *  @param Survey mapping Id.
     *  @return Caption of the section, or false if the section is not found (not suppose to happen).
     */
    getCaptionById : function(smId){
        var sectionRepeated = _.find(this.models, function(q){ return q.get(ID_ATTRIBUTE) == smId; });
        return isNotUndefined(sectionRepeated.get(CAPTION_ATTRIBUTE)) ? sectionRepeated.get(CAPTION_ATTRIBUTE) : false;
    }
});

var MasterObjectList = Backbone.Collection.extend({

    /**
    *   Creates the proper structure to send master object data to the server.
    */
    obtainRelationsData : function(){
        var objectRelationData = [];
        _.each(this.models, function(mo){
             var parentSMId = mo.get(PARENT_OBJECT_ATTR).id
             if(isNotUndefined(parentSMId)){
                var relationMapping             = {}
                relationMapping.parent          = parentSMId;
                relationMapping.relationObjects = mo.obtainRelationsData();
                objectRelationData.push(relationMapping);
             }
        });
        return objectRelationData;
    },

    /**
    *   Iterates over the Master object collection passing the data of the recently changed
    *   survey mapping.
    *   @param surveyMappingId Id of the survey mapping.
    *   @param fieldName Name of the selected field.
    *   @param fieldLabel Label of the selected field.
    */
    modifySMRelatedData : function(surveyMappingId, fieldName, fieldLabel){
        _.each(this.models, function(mo){
             mo.modifySMRelatedData(surveyMappingId, fieldName, fieldLabel);
        });
    },

    /**
    *   Modify survey mappings of the collection
    *   @param Master object relations.
    */
    setRelationFields : function(masterObjectRelations){
        _.each(this.models, function(mo){
             mo.setRelationFields(masterObjectRelations);
        });
    },

    rerenderRelations : function(){
        _.each(this.models, function(mo){
             mo.rerender();
        });
    },

    /**
    *   Called when a new SurveyMapping is created,
    *   Iterate over the collection, adding the new SurveyMapping to the Master object.
    */
    createNewSurveyMapping : function(surveyMappingId){
        _.each(this.models, function(mo){
             mo.addNewSM(surveyMappingId);
        });
    },

    /**
    *   Iterate over the collection, and removes the survey mapping from the master object,
    *   also removes the master object related to the deleted survey mapping.
    *   @param Id of the deleted survey.
    */
    removeSM : function(surveyIdToDelete){
        _.each(this.models, function(mo){
             mo.removeSM(surveyIdToDelete);
        });
        this.models = _.filter(this.models, function(mo){ return mo.get(PARENT_OBJECT_ATTR).id != surveyIdToDelete; });
        this.rerenderRelations();
    },

     /**
     * Look for the master object related with the idFieldLabel, and set the new IdField label.
     * @param idFieldId Id of the survey mapping whose idField change.
     * @param idFieldlabel New label of the idField.
     */
    setNewLabelIdField : function (idFieldId, idFieldlabel){
        var masterObjectToChange = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == idFieldId; });
        if(isNotUndefined(masterObjectToChange)){
            var parentObjectOfMaster = masterObjectToChange.get(PARENT_OBJECT_ATTR);
            parentObjectOfMaster.idFieldLabel = idFieldlabel;
            masterObjectToChange.set(PARENT_OBJECT_ATTR, parentObjectOfMaster);
            masterObjectToChange.rerender();
        }
    },

    /**
     * Obtain relations (with the format <child.Id, [field.Name, ...]>) of the survey mapping to be removed.
     * @param Survey mapping Id to remove.
     * @return List of the relations where the given Id is parent.
     */
    obtainRelationsOfGivenId : function(smToRemove){
        var listOfRelationsData  = {};
        var masterObjectToRemove = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == smToRemove; });
        if(isNotUndefined(masterObjectToRemove)){
            var listOfRelations = masterObjectToRemove.obtainRelationsData();
            if(listOfRelations.length > 0){
                _.each(listOfRelations, function(relation){
                    var childObject = relation.child;
                    var listFields  = [];
                    _.each(relation.fieldsRelated, function(fr){
                        listFields.push(fr);
                    });
                    listOfRelationsData[childObject] = listFields;
                });
            }
        }
        return listOfRelationsData;
    },

    /**
     *  Method in charge to obtain the size of fields selected (of the given name) set for the given survey mapping Id.
     *  It only can return 1 or 0, because there is a validation that prevents the user to map twice or more times
     *  the same fields to a given survey mapping. 
     *  @param smId Survey mapping Id.
     *  @param fieldName Field name.
     *  @return Size of the fields selected (of the given name) related to the given survey mapping Id.
     */
    getRelationsLengthOfGivenField : function(smId, fieldName){
        var masterObjectWithRelationSet = _.find(this.models, function(mo){ return mo.hasRelationForGivenField(smId, fieldName) ; });
        return isNotUndefined(masterObjectWithRelationSet) ? 1 : 0;
    },

    /**
     *  Method in charge to return what master object have the relation already assigned.
     *  @param smId Id of the survey mapping.
     *  @param fieldName Name of the field selected.
     *  @return "Fake" question (in order to be treated the same way when assigning errors) representing the master object.
     */
    obtainFieldsInUse : function(smId, fieldName){
        var masterObjectWithFieldSet = _.find(this.models, function(mo){ return mo.hasRelationForGivenField(smId, fieldName); });
        if(isNotUndefined(masterObjectWithFieldSet)){
            var fakeQuestionWithFieldInUse = masterObjectWithFieldSet.castToFakeQuestion();
        }
        return isNotUndefined(fakeQuestionWithFieldInUse) ? fakeQuestionWithFieldInUse : [];
    },

    /**
     *  Method in charge to disable the relations between master objects because are mapped to 
     *  differents repeats sections.
     *  @param smParentId Parent object Id.
     *  @param smChildId Child object Id.
     */
    disableRelationsBecauseDiffRepeats : function(smParentId, smChildId){
        var parentMasterObject = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == smParentId; });
        if(isNotUndefined(parentMasterObject)){
            parentMasterObject.setRelationDisabledBecauseDiffRepeats(smChildId);
        }
    },

    /**
     *  Method in charge to remove Id of disabled relations because are mapped to different repeat sections. 
     */
    removeDisabledRelationsBecauseDiffRepeats : function(){
        _.each(this.models, function(mo){
             mo.removeDisabledRelations();
        });
    },

    /**
     * Method in charge to set the attribute hasRespondant in the master object when a respondent field is setted.
     * @param isEmpty True if there is not field selected.
     * @param smId Survey mapping id.
     */
    setRespondentAttribute : function(isEmpty, smId){
       var masterObjectRelated = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == smId; });
       if(isNotUndefined(masterObjectRelated)){
           masterObjectRelated.setRespondent(isEmpty);
       }
    },

    /**
     * Obtain the list of ids of master object that has respondent setted.
     */
    obtainMasterObjectsIdRespondentSetted : function(){
        var listOfMasterWithRespondent = [];
        _.each(this.models, function(mo){ 
            if(isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && isNotUndefined(mo.get(PARENT_OBJECT_ATTR).id)){
                if(fMPage.questionSubmissionCollection.hasRespondedSetted(mo.get(PARENT_OBJECT_ATTR).id)){
                    listOfMasterWithRespondent.push(mo.get(PARENT_OBJECT_ATTR).id);
                }
            }
        });
        return listOfMasterWithRespondent;
    },
	
	/**
	 * Modify the isInterviewee attribute from the master object with given Id
	 * @param smId Survey mapping Id.
	 * @param isInterviewee Boolean that represents if the checkbox changed is checked or not.
	 */
	modifyIsInterviewee : function(smId, isInterviewee){
		if(isInterviewee){
			// Checkbox is checked so is possible that other master object were checked (and should be unchecked).
			var masterObjectToRemoveInterviewee   = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).isInterviewee; });
			if (isNotUndefined(masterObjectToRemoveInterviewee)) {
				var parentObjectToRemoveInt = masterObjectToRemoveInterviewee.get(PARENT_OBJECT_ATTR);
				parentObjectToRemoveInt.isInterviewee = false;
			}
		}
        var masterObjectToModifyInterviewee = _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).id == smId; });
        if(isNotUndefined(masterObjectToModifyInterviewee)){
			var parentObject           = masterObjectToModifyInterviewee.get(PARENT_OBJECT_ATTR);
			parentObject.isInterviewee = isInterviewee;
		}
	},

    /**
     * Returns the object that has "Use as interviewee" checked, undefined if no object has it.
     * @return Returns the object that has "Use as interviewee" checked.
     */
    getUseAsIntervieweeObject : function(){
        return _.find(this.models, function(mo){ return isNotUndefined(mo.get(PARENT_OBJECT_ATTR)) && mo.get(PARENT_OBJECT_ATTR).isInterviewee; });
    }

});

var NodeCollection = Backbone.Collection.extend({

    /**
     * Set parentId as parent in all children relations that have parentId as parent.
     * @param {Object} parentId Id of the node.
     * @param {Object} listOfChilds List of childs of the giving node.
     */
    setParentsNodes : function(parentId, listOfChilds){
        var self          = this;
        _.each(listOfChilds, function(childId){
            var childObj    = _.find(self.models, function(moC){ return moC.get(ID_ATTR) == childId ; });
            var parentArray = childObj.get(PARENTS_ATTR);
            parentArray.push(parentId);
        });
    },

    /**
     * At this point we only had nodes and their parents, in this method we set grand parents,
     * (parents of grand parents and so on) as parents of each node (in a recursive way).
     */
    setAncestors : function(){
        var self = this;
        _.each(this.models, function(childNode){
              childNode.setParentsRecursively(childNode, self.models);
        });
    },

    /**
     * Called when creating an empty survey mapping, this method is in charge to add the new potential survey mapping
     * to the list of parent relations nodes.
     * @param fakeSMId Fake id of the recently created survey mapping (with the format 'sc{x}')
     */
    createNewNodeRelation : function(fakeSMId){
        var newNode = new NodeModel();
        newNode.set(ID_ATTR, fakeSMId);
        this.add(newNode)
    },

    /**
     * Removes the survey mapping of the list of nodes.
     * @param surveyIdToDelete Survey mapping Id to remove.
     */
    removeNodeRelation : function(surveyIdToDelete){
        this.models = _.filter(this.models, function(node){ return node.get(ID_ATTR) != surveyIdToDelete; });
    },

    /**
     * This method clear the list of parents of all nodes (called when a relation change)
     */
    removeParentsOfNodes : function(){
        _.each(this.models, function(childNode){
              childNode.removeParents();
        });
    },

    /** 
     *  Given a survey mapping Id, returns the node related to that Id.
     *  @param smId Survey mapping Id.
     *  @return Node related.
     */
    findNodeById : function(smId){
        return _.find(this.models, function(node){ return node.get(ID_ATTR) == smId; });
    },

    /**
     *  Find if the parentId given is ancestor of the childId.
     *  @param parentId Parent Id.
     *  @param childId Child Id.
     *  @return True if parentId is ancestor of childId, false otherwise.
     */
    isAncestor : function(parentId, childId){
        var childNode    = this.findNodeById(childId);
        return childNode.isMyAncestor(parentId, this);
    },

    /**
     * Method in charge to retrieve parents (in a recursive way) of the parentId.
     * @param Id to look for parents.
     * @return List of the id's of the parents of the given Id.
     */
    getParentsOfNode : function(parentId){
        var listParentsOfNode = [];
        var firstParentOfNode = _.find(this.models, function(no){ return no.get(ID_ATTR) == parentId; });
        if(isNotUndefined(firstParentOfNode)){
            firstParentOfNode.setAncestorsToList(listParentsOfNode, this.models);
        }
        return listParentsOfNode;
    }
});
