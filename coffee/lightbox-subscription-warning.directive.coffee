module = angular.module("subscriptions")

LightboxSubscriptionWarning = (projectService, lightboxService, storageService) ->
    link = (scope, el, attrs) ->
        lightboxService.open(el)
        scope.i_am_owner = projectService.project.get('i_am_owner')
        scope.projectName = projectService.project.get('name')

        scope.close = () ->
            lightboxService.close(el)
            warning = storageService.get('payment-warning', [])
            warning.push(projectService.project.get('id'));

            storageService.set('payment-warning', warning)

            return

    return {
        templateUrl: 'compile-modules/taiga-contrib-subscriptions/partials/lightbox-subscription-warning.html',
        link: link
    }

LightboxSubscriptionWarning.$inject = [
    "tgProjectService",
    "lightboxService",
    "$tgStorage"
]

module.directive("tgLightboxSubscriptionWarning", LightboxSubscriptionWarning)
