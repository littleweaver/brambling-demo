from django.conf.urls import patterns, include, url
from django.contrib import admin

urlpatterns = patterns('',
    url(r'^admin/', include(admin.site.urls)),
    url(r'^feedback/', include('zenaida.contrib.feedback.urls')),
    url(r'^hints/', include('zenaida.contrib.hints.urls')),
    url(r'^', include('brambling.urls')),
)
