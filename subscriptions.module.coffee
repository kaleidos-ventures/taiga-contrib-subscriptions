moduleName = 'subscriptions'

window.taigaContribPlugins = [] if !window.taigaContribPlugins

window.taigaContribPlugins.push({
    type: 'userSettings',
    template: 'compile-modules/taiga-contrib-subscriptions/partials/subscriptions.html',
    name: 'Paid Plans',
    slug: 'subscriptions',
    module: moduleName,
    userMenu: true
})

init = (projectService, lightboxFactory, $rootScope, translatePartialLoader, storageService) ->
    $rootScope.$applyAsync () ->
        translatePartialLoader.addPart('taiga-contrib-subscriptions')


    # subscription payments warning message
    checkProjectsSubscriptions = (project) ->
        warnings = storageService.get('payment-warning', [])

        if project?.get('is_out_of_owner_limits') && project.get('i_am_member') && warnings.indexOf(project.get('id')) == -1
            lightboxFactory.create('tg-lightbox-subscription-warning', {
                class: 'lightbox lightbox-payments-warning'
            })

    $rootScope.$watch () ->
        return projectService.project
    , checkProjectsSubscriptions

angular.module(moduleName, []).run([
    "tgProjectService",
    "tgLightboxFactory",
    "$rootScope",
    "$translatePartialLoader",
    "$tgStorage"
    init
])
