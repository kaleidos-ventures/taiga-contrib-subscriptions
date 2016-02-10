module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService"
    ]

    constructor: (@appMetaService,  @subscriptionsService) ->
        pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @.sectionName = "Upgrade Plan"
        console.log @.sectionName

        #@.myRecommendedPlan = @subscriptionsService.getMyRecommendedPlan()

        title = pluginName
        description = @.sectionName
        @appMetaService.setAll(title, description)

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
