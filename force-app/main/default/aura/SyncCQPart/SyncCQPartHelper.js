({
	syncProduct : function(component, event, helper) {
		component.set("v.isLoading",true);
        var action = component.get("c.syncRequirePart");
        action.setCallback(this,function(a){
            var state = a.getState();
            if(state === "SUCCESS"){
                component.set("v.isLoading",false);
                var result = a.getReturnValue();
                helper.showToastMessage(component, event,result,'Success');
            } else if(state === "ERROR"){
                component.set("v.isLoading",false);
                var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                         helper.showToastMessage(component, event,errors[0].message ,'Error');
                    }
                }
            }
            else if (status === "INCOMPLETE") {
                component.set("v.isLoading",false);
                helper.showToastMessage(component, event, 'No response from server or client is offline.','Error')
            }
        });       
        $A.enqueueAction(action);
	},
    
    showToastMessage : function(component, event, message,title) {
		 var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: 'info',
            mode: 'dismissible'
        });
        toastEvent.fire();
	},
    
})