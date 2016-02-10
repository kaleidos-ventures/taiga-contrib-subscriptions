module = angular.module('subscriptions')

class SubscriptionsAdmin
    @.$inject = [
        "tgAppMetaService",
        "ContribSubscriptionsService"
        "$translate"
    ]

    constructor: (@appMetaService,  @subscriptionsService, @translate) ->
        pluginName = "Subscriptions - User Profile - Taiga" # i18n
        @.sectionName = "Upgrade Plan"

        promise = @subscriptionsService.getMyRecommendedPlan()
        promise.then (response) =>
            console.log response
            @.myRecommendedPlan = response

            @.limitPrivateProjects = @translate.instant("SUBSCRIPTIONS.PRIVATE_PROJECTS_LIMIT", {"limit": @.myRecommendedPlan.private_projects})
            @.limitMembersProjects = @translate.instant("SUBSCRIPTIONS.MEMBERS_LIMIT", {"limit": @.myRecommendedPlan.project_members})

        title = pluginName
        description = @.sectionName
        @appMetaService.setAll(title, description)

module.controller("ContribSubscriptionsController", SubscriptionsAdmin)
