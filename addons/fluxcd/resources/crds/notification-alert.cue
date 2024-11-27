package main

notificationAlertCRD: {
	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		annotations: "controller-gen.kubebuilder.io/version": "v0.16.1"
		labels: {
			"app.kubernetes.io/component": "notification-controller"
			"app.kubernetes.io/instance":  "flux-system"
			"app.kubernetes.io/part-of":   "flux"
			"app.kubernetes.io/version":   "v2.4.0"
		}
		name: "alerts.notification.toolkit.fluxcd.io"
	}
	spec: {
		group: "notification.toolkit.fluxcd.io"
		names: {
			kind:     "Alert"
			listKind: "AlertList"
			plural:   "alerts"
			singular: "alert"
		}
		scope: "Namespaced"
		versions: [{
			additionalPrinterColumns: [{
				jsonPath: ".metadata.creationTimestamp"
				name:     "Age"
				type:     "date"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
				name:     "Ready"
				type:     "string"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].message"
				name:     "Status"
				type:     "string"
			}]
			deprecated:         true
			deprecationWarning: "v1beta1 Alert is deprecated, upgrade to v1beta3"
			name:               "v1beta1"
			schema: openAPIV3Schema: {
				description: "Alert is the Schema for the alerts API"
				properties: {
					apiVersion: {
						description: """
									APIVersion defines the versioned schema of this representation of an object.
									Servers should convert recognized schemas to the latest internal value, and
									may reject unrecognized values.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
									"""
						type: "string"
					}
					kind: {
						description: """
									Kind is a string value representing the REST resource this object represents.
									Servers may infer this from the endpoint the client submits requests to.
									Cannot be updated.
									In CamelCase.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
									"""
						type: "string"
					}
					metadata: type: "object"
					spec: {
						description: "AlertSpec defines an alerting rule for events involving a list of objects"
						properties: {
							eventSeverity: {
								default: "info"
								description: """
											Filter events based on severity, defaults to ('info').
											If set to 'info' no events will be filtered.
											"""
								enum: ["info", "error"]
								type: "string"
							}
							eventSources: {
								description: "Filter events based on the involved objects."
								items: {
									description: """
												CrossNamespaceObjectReference contains enough information to let you locate the
												typed referenced object at cluster level
												"""
									properties: {
										apiVersion: {
											description: "API version of the referent"
											type:        "string"
										}
										kind: {
											description: "Kind of the referent"
											enum: ["Bucket", "GitRepository", "Kustomization", "HelmRelease", "HelmChart", "HelmRepository", "ImageRepository", "ImagePolicy", "ImageUpdateAutomation", "OCIRepository"]
											type: "string"
										}
										matchLabels: {
											additionalProperties: type: "string"
											description: """
														MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
														map is equivalent to an element of matchExpressions, whose key field is "key", the
														operator is "In", and the values array contains only "value". The requirements are ANDed.
														"""
											type: "object"
										}
										name: {
											description: "Name of the referent"
											maxLength:   53
											minLength:   1
											type:        "string"
										}
										namespace: {
											description: "Namespace of the referent"
											maxLength:   53
											minLength:   1
											type:        "string"
										}
									}
									required: ["kind", "name"]
									type: "object"
								}
								type: "array"
							}
							exclusionList: {
								description: "A list of Golang regular expressions to be used for excluding messages."
								items: type: "string"
								type: "array"
							}
							providerRef: {
								description: "Send events using this provider."
								properties: name: {
									description: "Name of the referent."
									type:        "string"
								}
								required: ["name"]
								type: "object"
							}
							summary: {
								description: "Short description of the impact and affected cluster."
								type:        "string"
							}
							suspend: {
								description: """
											This flag tells the controller to suspend subsequent events dispatching.
											Defaults to false.
											"""
								type: "boolean"
							}
						}
						required: ["eventSources", "providerRef"]
						type: "object"
					}
					status: {
						default: observedGeneration: -1
						description: "AlertStatus defines the observed state of Alert"
						properties: {
							conditions: {
								items: {
									description: "Condition contains details for one aspect of the current state of this API Resource."
									properties: {
										lastTransitionTime: {
											description: """
														lastTransitionTime is the last time the condition transitioned from one status to another.
														This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
														"""
											format: "date-time"
											type:   "string"
										}
										message: {
											description: """
														message is a human readable message indicating details about the transition.
														This may be an empty string.
														"""
											maxLength: 32768
											type:      "string"
										}
										observedGeneration: {
											description: """
														observedGeneration represents the .metadata.generation that the condition was set based upon.
														For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date
														with respect to the current state of the instance.
														"""
											format:  "int64"
											minimum: 0
											type:    "integer"
										}
										reason: {
											description: """
														reason contains a programmatic identifier indicating the reason for the condition's last transition.
														Producers of specific condition types may define expected values and meanings for this field,
														and whether the values are considered a guaranteed API.
														The value should be a CamelCase string.
														This field may not be empty.
														"""
											maxLength: 1024
											minLength: 1
											pattern:   "^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$"
											type:      "string"
										}
										status: {
											description: "status of the condition, one of True, False, Unknown."
											enum: ["True", "False", "Unknown"]
											type: "string"
										}
										type: {
											description: "type of condition in CamelCase or in foo.example.com/CamelCase."
											maxLength:   316
											pattern:     "^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$"
											type:        "string"
										}
									}
									required: ["lastTransitionTime", "message", "reason", "status", "type"]
									type: "object"
								}
								type: "array"
							}
							observedGeneration: {
								description: "ObservedGeneration is the last observed generation."
								format:      "int64"
								type:        "integer"
							}
						}
						type: "object"
					}
				}
				type: "object"
			}
			served:  true
			storage: false
			subresources: status: {}
		}, {
			additionalPrinterColumns: [{
				jsonPath: ".metadata.creationTimestamp"
				name:     "Age"
				type:     "date"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
				name:     "Ready"
				type:     "string"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].message"
				name:     "Status"
				type:     "string"
			}]
			deprecated:         true
			deprecationWarning: "v1beta2 Alert is deprecated, upgrade to v1beta3"
			name:               "v1beta2"
			schema: openAPIV3Schema: {
				description: "Alert is the Schema for the alerts API"
				properties: {
					apiVersion: {
						description: """
									APIVersion defines the versioned schema of this representation of an object.
									Servers should convert recognized schemas to the latest internal value, and
									may reject unrecognized values.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
									"""
						type: "string"
					}
					kind: {
						description: """
									Kind is a string value representing the REST resource this object represents.
									Servers may infer this from the endpoint the client submits requests to.
									Cannot be updated.
									In CamelCase.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
									"""
						type: "string"
					}
					metadata: type: "object"
					spec: {
						description: "AlertSpec defines an alerting rule for events involving a list of objects."
						properties: {
							eventMetadata: {
								additionalProperties: type: "string"
								description: """
											EventMetadata is an optional field for adding metadata to events dispatched by the
											controller. This can be used for enhancing the context of the event. If a field
											would override one already present on the original event as generated by the emitter,
											then the override doesn't happen, i.e. the original value is preserved, and an info
											log is printed.
											"""
								type: "object"
							}
							eventSeverity: {
								default: "info"
								description: """
											EventSeverity specifies how to filter events based on severity.
											If set to 'info' no events will be filtered.
											"""
								enum: ["info", "error"]
								type: "string"
							}
							eventSources: {
								description: """
											EventSources specifies how to filter events based
											on the involved object kind, name and namespace.
											"""
								items: {
									description: """
												CrossNamespaceObjectReference contains enough information to let you locate the
												typed referenced object at cluster level
												"""
									properties: {
										apiVersion: {
											description: "API version of the referent"
											type:        "string"
										}
										kind: {
											description: "Kind of the referent"
											enum: ["Bucket", "GitRepository", "Kustomization", "HelmRelease", "HelmChart", "HelmRepository", "ImageRepository", "ImagePolicy", "ImageUpdateAutomation", "OCIRepository"]
											type: "string"
										}
										matchLabels: {
											additionalProperties: type: "string"
											description: """
														MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
														map is equivalent to an element of matchExpressions, whose key field is "key", the
														operator is "In", and the values array contains only "value". The requirements are ANDed.
														MatchLabels requires the name to be set to `*`.
														"""
											type: "object"
										}
										name: {
											description: """
														Name of the referent
														If multiple resources are targeted `*` may be set.
														"""
											maxLength: 53
											minLength: 1
											type:      "string"
										}
										namespace: {
											description: "Namespace of the referent"
											maxLength:   53
											minLength:   1
											type:        "string"
										}
									}
									required: ["kind", "name"]
									type: "object"
								}
								type: "array"
							}
							exclusionList: {
								description: """
											ExclusionList specifies a list of Golang regular expressions
											to be used for excluding messages.
											"""
								items: type: "string"
								type: "array"
							}
							inclusionList: {
								description: """
											InclusionList specifies a list of Golang regular expressions
											to be used for including messages.
											"""
								items: type: "string"
								type: "array"
							}
							providerRef: {
								description: "ProviderRef specifies which Provider this Alert should use."
								properties: name: {
									description: "Name of the referent."
									type:        "string"
								}
								required: ["name"]
								type: "object"
							}
							summary: {
								description: "Summary holds a short description of the impact and affected cluster."
								maxLength:   255
								type:        "string"
							}
							suspend: {
								description: """
											Suspend tells the controller to suspend subsequent
											events handling for this Alert.
											"""
								type: "boolean"
							}
						}
						required: ["eventSources", "providerRef"]
						type: "object"
					}
					status: {
						default: observedGeneration: -1
						description: "AlertStatus defines the observed state of the Alert."
						properties: {
							conditions: {
								description: "Conditions holds the conditions for the Alert."
								items: {
									description: "Condition contains details for one aspect of the current state of this API Resource."
									properties: {
										lastTransitionTime: {
											description: """
														lastTransitionTime is the last time the condition transitioned from one status to another.
														This should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.
														"""
											format: "date-time"
											type:   "string"
										}
										message: {
											description: """
														message is a human readable message indicating details about the transition.
														This may be an empty string.
														"""
											maxLength: 32768
											type:      "string"
										}
										observedGeneration: {
											description: """
														observedGeneration represents the .metadata.generation that the condition was set based upon.
														For instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date
														with respect to the current state of the instance.
														"""
											format:  "int64"
											minimum: 0
											type:    "integer"
										}
										reason: {
											description: """
														reason contains a programmatic identifier indicating the reason for the condition's last transition.
														Producers of specific condition types may define expected values and meanings for this field,
														and whether the values are considered a guaranteed API.
														The value should be a CamelCase string.
														This field may not be empty.
														"""
											maxLength: 1024
											minLength: 1
											pattern:   "^[A-Za-z]([A-Za-z0-9_,:]*[A-Za-z0-9_])?$"
											type:      "string"
										}
										status: {
											description: "status of the condition, one of True, False, Unknown."
											enum: ["True", "False", "Unknown"]
											type: "string"
										}
										type: {
											description: "type of condition in CamelCase or in foo.example.com/CamelCase."
											maxLength:   316
											pattern:     "^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*/)?(([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9])$"
											type:        "string"
										}
									}
									required: ["lastTransitionTime", "message", "reason", "status", "type"]
									type: "object"
								}
								type: "array"
							}
							lastHandledReconcileAt: {
								description: """
											LastHandledReconcileAt holds the value of the most recent
											reconcile request value, so a change of the annotation value
											can be detected.
											"""
								type: "string"
							}
							observedGeneration: {
								description: "ObservedGeneration is the last observed generation."
								format:      "int64"
								type:        "integer"
							}
						}
						type: "object"
					}
				}
				type: "object"
			}
			served:  true
			storage: false
			subresources: status: {}
		}, {
			additionalPrinterColumns: [{
				jsonPath: ".metadata.creationTimestamp"
				name:     "Age"
				type:     "date"
			}]
			name: "v1beta3"
			schema: openAPIV3Schema: {
				description: "Alert is the Schema for the alerts API"
				properties: {
					apiVersion: {
						description: """
									APIVersion defines the versioned schema of this representation of an object.
									Servers should convert recognized schemas to the latest internal value, and
									may reject unrecognized values.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources
									"""
						type: "string"
					}
					kind: {
						description: """
									Kind is a string value representing the REST resource this object represents.
									Servers may infer this from the endpoint the client submits requests to.
									Cannot be updated.
									In CamelCase.
									More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds
									"""
						type: "string"
					}
					metadata: type: "object"
					spec: {
						description: "AlertSpec defines an alerting rule for events involving a list of objects."
						properties: {
							eventMetadata: {
								additionalProperties: type: "string"
								description: """
											EventMetadata is an optional field for adding metadata to events dispatched by the
											controller. This can be used for enhancing the context of the event. If a field
											would override one already present on the original event as generated by the emitter,
											then the override doesn't happen, i.e. the original value is preserved, and an info
											log is printed.
											"""
								type: "object"
							}
							eventSeverity: {
								default: "info"
								description: """
											EventSeverity specifies how to filter events based on severity.
											If set to 'info' no events will be filtered.
											"""
								enum: ["info", "error"]
								type: "string"
							}
							eventSources: {
								description: """
											EventSources specifies how to filter events based
											on the involved object kind, name and namespace.
											"""
								items: {
									description: """
												CrossNamespaceObjectReference contains enough information to let you locate the
												typed referenced object at cluster level
												"""
									properties: {
										apiVersion: {
											description: "API version of the referent"
											type:        "string"
										}
										kind: {
											description: "Kind of the referent"
											enum: ["Bucket", "GitRepository", "Kustomization", "HelmRelease", "HelmChart", "HelmRepository", "ImageRepository", "ImagePolicy", "ImageUpdateAutomation", "OCIRepository"]
											type: "string"
										}
										matchLabels: {
											additionalProperties: type: "string"
											description: """
														MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
														map is equivalent to an element of matchExpressions, whose key field is "key", the
														operator is "In", and the values array contains only "value". The requirements are ANDed.
														MatchLabels requires the name to be set to `*`.
														"""
											type: "object"
										}
										name: {
											description: """
														Name of the referent
														If multiple resources are targeted `*` may be set.
														"""
											maxLength: 53
											minLength: 1
											type:      "string"
										}
										namespace: {
											description: "Namespace of the referent"
											maxLength:   53
											minLength:   1
											type:        "string"
										}
									}
									required: ["kind", "name"]
									type: "object"
								}
								type: "array"
							}
							exclusionList: {
								description: """
											ExclusionList specifies a list of Golang regular expressions
											to be used for excluding messages.
											"""
								items: type: "string"
								type: "array"
							}
							inclusionList: {
								description: """
											InclusionList specifies a list of Golang regular expressions
											to be used for including messages.
											"""
								items: type: "string"
								type: "array"
							}
							providerRef: {
								description: "ProviderRef specifies which Provider this Alert should use."
								properties: name: {
									description: "Name of the referent."
									type:        "string"
								}
								required: ["name"]
								type: "object"
							}
							summary: {
								description: "Summary holds a short description of the impact and affected cluster."
								maxLength:   255
								type:        "string"
							}
							suspend: {
								description: """
											Suspend tells the controller to suspend subsequent
											events handling for this Alert.
											"""
								type: "boolean"
							}
						}
						required: ["eventSources", "providerRef"]
						type: "object"
					}
				}
				type: "object"
			}
			served:  true
			storage: true
			subresources: {}
		}]
	}
}