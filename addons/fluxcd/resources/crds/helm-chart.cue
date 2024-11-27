package main

helmChartCRD: {
	apiVersion: "apiextensions.k8s.io/v1"
	kind:       "CustomResourceDefinition"
	metadata: {
		annotations: "controller-gen.kubebuilder.io/version": "v0.16.1"
		labels: {
			"app.kubernetes.io/component": "source-controller"
			"app.kubernetes.io/instance":  "flux-system"
			"app.kubernetes.io/part-of":   "flux"
			"app.kubernetes.io/version":   "v2.4.0"
		}
		name: "helmcharts.source.toolkit.fluxcd.io"
	}
	spec: {
		group: "source.toolkit.fluxcd.io"
		names: {
			kind:     "HelmChart"
			listKind: "HelmChartList"
			plural:   "helmcharts"
			shortNames: ["hc"]
			singular: "helmchart"
		}
		scope: "Namespaced"
		versions: [{
			additionalPrinterColumns: [{
				jsonPath: ".spec.chart"
				name:     "Chart"
				type:     "string"
			}, {
				jsonPath: ".spec.version"
				name:     "Version"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.kind"
				name:     "Source Kind"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.name"
				name:     "Source Name"
				type:     "string"
			}, {
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
			name: "v1"
			schema: openAPIV3Schema: {
				description: "HelmChart is the Schema for the helmcharts API."
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
						description: "HelmChartSpec specifies the desired state of a Helm chart."
						properties: {
							chart: {
								description: """
											Chart is the name or path the Helm chart is available at in the
											SourceRef.
											"""
								type: "string"
							}
							ignoreMissingValuesFiles: {
								description: """
											IgnoreMissingValuesFiles controls whether to silently ignore missing values
											files rather than failing.
											"""
								type: "boolean"
							}
							interval: {
								description: """
											Interval at which the HelmChart SourceRef is checked for updates.
											This interval is approximate and may be subject to jitter to ensure
											efficient use of resources.
											"""
								pattern: "^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"
								type:    "string"
							}
							reconcileStrategy: {
								default: "ChartVersion"
								description: """
											ReconcileStrategy determines what enables the creation of a new artifact.
											Valid values are ('ChartVersion', 'Revision').
											See the documentation of the values for an explanation on their behavior.
											Defaults to ChartVersion when omitted.
											"""
								enum: ["ChartVersion", "Revision"]
								type: "string"
							}
							sourceRef: {
								description: "SourceRef is the reference to the Source the chart is available at."
								properties: {
									apiVersion: {
										description: "APIVersion of the referent."
										type:        "string"
									}
									kind: {
										description: """
													Kind of the referent, valid values are ('HelmRepository', 'GitRepository',
													'Bucket').
													"""
										enum: ["HelmRepository", "GitRepository", "Bucket"]
										type: "string"
									}
									name: {
										description: "Name of the referent."
										type:        "string"
									}
								}
								required: ["kind", "name"]
								type: "object"
							}
							suspend: {
								description: """
											Suspend tells the controller to suspend the reconciliation of this
											source.
											"""
								type: "boolean"
							}
							valuesFiles: {
								description: """
											ValuesFiles is an alternative list of values files to use as the chart
											values (values.yaml is not included by default), expected to be a
											relative path in the SourceRef.
											Values files are merged in the order of this list with the last file
											overriding the first. Ignored when omitted.
											"""
								items: type: "string"
								type: "array"
							}
							verify: {
								description: """
											Verify contains the secret name containing the trusted public keys
											used to verify the signature and specifies which provider to use to check
											whether OCI image is authentic.
											This field is only supported when using HelmRepository source with spec.type 'oci'.
											Chart dependencies, which are not bundled in the umbrella chart artifact, are not verified.
											"""
								properties: {
									matchOIDCIdentity: {
										description: """
													MatchOIDCIdentity specifies the identity matching criteria to use
													while verifying an OCI artifact which was signed using Cosign keyless
													signing. The artifact's identity is deemed to be verified if any of the
													specified matchers match against the identity.
													"""
										items: {
											description: """
														OIDCIdentityMatch specifies options for verifying the certificate identity,
														i.e. the issuer and the subject of the certificate.
														"""
											properties: {
												issuer: {
													description: """
																Issuer specifies the regex pattern to match against to verify
																the OIDC issuer in the Fulcio certificate. The pattern must be a
																valid Go regular expression.
																"""
													type: "string"
												}
												subject: {
													description: """
																Subject specifies the regex pattern to match against to verify
																the identity subject in the Fulcio certificate. The pattern must
																be a valid Go regular expression.
																"""
													type: "string"
												}
											}
											required: ["issuer", "subject"]
											type: "object"
										}
										type: "array"
									}
									provider: {
										default:     "cosign"
										description: "Provider specifies the technology used to sign the OCI Artifact."
										enum: ["cosign", "notation"]
										type: "string"
									}
									secretRef: {
										description: """
													SecretRef specifies the Kubernetes Secret containing the
													trusted public keys.
													"""
										properties: name: {
											description: "Name of the referent."
											type:        "string"
										}
										required: ["name"]
										type: "object"
									}
								}
								required: ["provider"]
								type: "object"
							}
							version: {
								default: "*"
								description: """
											Version is the chart version semver expression, ignored for charts from
											GitRepository and Bucket sources. Defaults to latest when omitted.
											"""
								type: "string"
							}
						}
						required: ["chart", "interval", "sourceRef"]
						type: "object"
					}
					status: {
						default: observedGeneration: -1
						description: "HelmChartStatus records the observed state of the HelmChart."
						properties: {
							artifact: {
								description: "Artifact represents the output of the last successful reconciliation."
								properties: {
									digest: {
										description: "Digest is the digest of the file in the form of '<algorithm>:<checksum>'."
										pattern:     "^[a-z0-9]+(?:[.+_-][a-z0-9]+)*:[a-zA-Z0-9=_-]+$"
										type:        "string"
									}
									lastUpdateTime: {
										description: """
													LastUpdateTime is the timestamp corresponding to the last update of the
													Artifact.
													"""
										format: "date-time"
										type:   "string"
									}
									metadata: {
										additionalProperties: type: "string"
										description: "Metadata holds upstream information such as OCI annotations."
										type:        "object"
									}
									path: {
										description: """
													Path is the relative file path of the Artifact. It can be used to locate
													the file in the root of the Artifact storage on the local file system of
													the controller managing the Source.
													"""
										type: "string"
									}
									revision: {
										description: """
													Revision is a human-readable identifier traceable in the origin source
													system. It can be a Git commit SHA, Git tag, a Helm chart version, etc.
													"""
										type: "string"
									}
									size: {
										description: "Size is the number of bytes in the file."
										format:      "int64"
										type:        "integer"
									}
									url: {
										description: """
													URL is the HTTP address of the Artifact as exposed by the controller
													managing the Source. It can be used to retrieve the Artifact for
													consumption, e.g. by another controller applying the Artifact contents.
													"""
										type: "string"
									}
								}
								required: ["lastUpdateTime", "path", "revision", "url"]
								type: "object"
							}
							conditions: {
								description: "Conditions holds the conditions for the HelmChart."
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
							observedChartName: {
								description: """
											ObservedChartName is the last observed chart name as specified by the
											resolved chart reference.
											"""
								type: "string"
							}
							observedGeneration: {
								description: """
											ObservedGeneration is the last observed generation of the HelmChart
											object.
											"""
								format: "int64"
								type:   "integer"
							}
							observedSourceArtifactRevision: {
								description: """
											ObservedSourceArtifactRevision is the last observed Artifact.Revision
											of the HelmChartSpec.SourceRef.
											"""
								type: "string"
							}
							observedValuesFiles: {
								description: """
											ObservedValuesFiles are the observed value files of the last successful
											reconciliation.
											It matches the chart in the last successfully reconciled artifact.
											"""
								items: type: "string"
								type: "array"
							}
							url: {
								description: """
											URL is the dynamic fetch link for the latest Artifact.
											It is provided on a "best effort" basis, and using the precise
											BucketStatus.Artifact data is recommended.
											"""
								type: "string"
							}
						}
						type: "object"
					}
				}
				type: "object"
			}
			served:  true
			storage: true
			subresources: status: {}
		}, {
			additionalPrinterColumns: [{
				jsonPath: ".spec.chart"
				name:     "Chart"
				type:     "string"
			}, {
				jsonPath: ".spec.version"
				name:     "Version"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.kind"
				name:     "Source Kind"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.name"
				name:     "Source Name"
				type:     "string"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].status"
				name:     "Ready"
				type:     "string"
			}, {
				jsonPath: ".status.conditions[?(@.type==\"Ready\")].message"
				name:     "Status"
				type:     "string"
			}, {
				jsonPath: ".metadata.creationTimestamp"
				name:     "Age"
				type:     "date"
			}]
			deprecated:         true
			deprecationWarning: "v1beta1 HelmChart is deprecated, upgrade to v1"
			name:               "v1beta1"
			schema: openAPIV3Schema: {
				description: "HelmChart is the Schema for the helmcharts API"
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
						description: "HelmChartSpec defines the desired state of a Helm chart."
						properties: {
							accessFrom: {
								description: "AccessFrom defines an Access Control List for allowing cross-namespace references to this object."
								properties: namespaceSelectors: {
									description: """
													NamespaceSelectors is the list of namespace selectors to which this ACL applies.
													Items in this list are evaluated using a logical OR operation.
													"""
									items: {
										description: """
														NamespaceSelector selects the namespaces to which this ACL applies.
														An empty map of MatchLabels matches all namespaces in a cluster.
														"""
										properties: matchLabels: {
											additionalProperties: type: "string"
											description: """
																MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
																map is equivalent to an element of matchExpressions, whose key field is "key", the
																operator is "In", and the values array contains only "value". The requirements are ANDed.
																"""
											type: "object"
										}
										type: "object"
									}
									type: "array"
								}
								required: ["namespaceSelectors"]
								type: "object"
							}
							chart: {
								description: "The name or path the Helm chart is available at in the SourceRef."
								type:        "string"
							}
							interval: {
								description: "The interval at which to check the Source for updates."
								type:        "string"
							}
							reconcileStrategy: {
								default: "ChartVersion"
								description: """
											Determines what enables the creation of a new artifact. Valid values are
											('ChartVersion', 'Revision').
											See the documentation of the values for an explanation on their behavior.
											Defaults to ChartVersion when omitted.
											"""
								enum: ["ChartVersion", "Revision"]
								type: "string"
							}
							sourceRef: {
								description: "The reference to the Source the chart is available at."
								properties: {
									apiVersion: {
										description: "APIVersion of the referent."
										type:        "string"
									}
									kind: {
										description: """
													Kind of the referent, valid values are ('HelmRepository', 'GitRepository',
													'Bucket').
													"""
										enum: ["HelmRepository", "GitRepository", "Bucket"]
										type: "string"
									}
									name: {
										description: "Name of the referent."
										type:        "string"
									}
								}
								required: ["kind", "name"]
								type: "object"
							}
							suspend: {
								description: "This flag tells the controller to suspend the reconciliation of this source."
								type:        "boolean"
							}
							valuesFile: {
								description: """
											Alternative values file to use as the default chart values, expected to
											be a relative path in the SourceRef. Deprecated in favor of ValuesFiles,
											for backwards compatibility the file defined here is merged before the
											ValuesFiles items. Ignored when omitted.
											"""
								type: "string"
							}
							valuesFiles: {
								description: """
											Alternative list of values files to use as the chart values (values.yaml
											is not included by default), expected to be a relative path in the SourceRef.
											Values files are merged in the order of this list with the last file overriding
											the first. Ignored when omitted.
											"""
								items: type: "string"
								type: "array"
							}
							version: {
								default: "*"
								description: """
											The chart version semver expression, ignored for charts from GitRepository
											and Bucket sources. Defaults to latest when omitted.
											"""
								type: "string"
							}
						}
						required: ["chart", "interval", "sourceRef"]
						type: "object"
					}
					status: {
						default: observedGeneration: -1
						description: "HelmChartStatus defines the observed state of the HelmChart."
						properties: {
							artifact: {
								description: "Artifact represents the output of the last successful chart sync."
								properties: {
									checksum: {
										description: "Checksum is the SHA256 checksum of the artifact."
										type:        "string"
									}
									lastUpdateTime: {
										description: """
													LastUpdateTime is the timestamp corresponding to the last update of this
													artifact.
													"""
										format: "date-time"
										type:   "string"
									}
									path: {
										description: "Path is the relative file path of this artifact."
										type:        "string"
									}
									revision: {
										description: """
													Revision is a human readable identifier traceable in the origin source
													system. It can be a Git commit SHA, Git tag, a Helm index timestamp, a Helm
													chart version, etc.
													"""
										type: "string"
									}
									url: {
										description: "URL is the HTTP address of this artifact."
										type:        "string"
									}
								}
								required: ["lastUpdateTime", "path", "url"]
								type: "object"
							}
							conditions: {
								description: "Conditions holds the conditions for the HelmChart."
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
							url: {
								description: "URL is the download link for the last chart pulled."
								type:        "string"
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
				jsonPath: ".spec.chart"
				name:     "Chart"
				type:     "string"
			}, {
				jsonPath: ".spec.version"
				name:     "Version"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.kind"
				name:     "Source Kind"
				type:     "string"
			}, {
				jsonPath: ".spec.sourceRef.name"
				name:     "Source Name"
				type:     "string"
			}, {
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
			deprecationWarning: "v1beta2 HelmChart is deprecated, upgrade to v1"
			name:               "v1beta2"
			schema: openAPIV3Schema: {
				description: "HelmChart is the Schema for the helmcharts API."
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
						description: "HelmChartSpec specifies the desired state of a Helm chart."
						properties: {
							accessFrom: {
								description: """
											AccessFrom specifies an Access Control List for allowing cross-namespace
											references to this object.
											NOTE: Not implemented, provisional as of https://github.com/fluxcd/flux2/pull/2092
											"""
								properties: namespaceSelectors: {
									description: """
													NamespaceSelectors is the list of namespace selectors to which this ACL applies.
													Items in this list are evaluated using a logical OR operation.
													"""
									items: {
										description: """
														NamespaceSelector selects the namespaces to which this ACL applies.
														An empty map of MatchLabels matches all namespaces in a cluster.
														"""
										properties: matchLabels: {
											additionalProperties: type: "string"
											description: """
																MatchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels
																map is equivalent to an element of matchExpressions, whose key field is "key", the
																operator is "In", and the values array contains only "value". The requirements are ANDed.
																"""
											type: "object"
										}
										type: "object"
									}
									type: "array"
								}
								required: ["namespaceSelectors"]
								type: "object"
							}
							chart: {
								description: """
											Chart is the name or path the Helm chart is available at in the
											SourceRef.
											"""
								type: "string"
							}
							ignoreMissingValuesFiles: {
								description: """
											IgnoreMissingValuesFiles controls whether to silently ignore missing values
											files rather than failing.
											"""
								type: "boolean"
							}
							interval: {
								description: """
											Interval at which the HelmChart SourceRef is checked for updates.
											This interval is approximate and may be subject to jitter to ensure
											efficient use of resources.
											"""
								pattern: "^([0-9]+(\\.[0-9]+)?(ms|s|m|h))+$"
								type:    "string"
							}
							reconcileStrategy: {
								default: "ChartVersion"
								description: """
											ReconcileStrategy determines what enables the creation of a new artifact.
											Valid values are ('ChartVersion', 'Revision').
											See the documentation of the values for an explanation on their behavior.
											Defaults to ChartVersion when omitted.
											"""
								enum: ["ChartVersion", "Revision"]
								type: "string"
							}
							sourceRef: {
								description: "SourceRef is the reference to the Source the chart is available at."
								properties: {
									apiVersion: {
										description: "APIVersion of the referent."
										type:        "string"
									}
									kind: {
										description: """
													Kind of the referent, valid values are ('HelmRepository', 'GitRepository',
													'Bucket').
													"""
										enum: ["HelmRepository", "GitRepository", "Bucket"]
										type: "string"
									}
									name: {
										description: "Name of the referent."
										type:        "string"
									}
								}
								required: ["kind", "name"]
								type: "object"
							}
							suspend: {
								description: """
											Suspend tells the controller to suspend the reconciliation of this
											source.
											"""
								type: "boolean"
							}
							valuesFile: {
								description: """
											ValuesFile is an alternative values file to use as the default chart
											values, expected to be a relative path in the SourceRef. Deprecated in
											favor of ValuesFiles, for backwards compatibility the file specified here
											is merged before the ValuesFiles items. Ignored when omitted.
											"""
								type: "string"
							}
							valuesFiles: {
								description: """
											ValuesFiles is an alternative list of values files to use as the chart
											values (values.yaml is not included by default), expected to be a
											relative path in the SourceRef.
											Values files are merged in the order of this list with the last file
											overriding the first. Ignored when omitted.
											"""
								items: type: "string"
								type: "array"
							}
							verify: {
								description: """
											Verify contains the secret name containing the trusted public keys
											used to verify the signature and specifies which provider to use to check
											whether OCI image is authentic.
											This field is only supported when using HelmRepository source with spec.type 'oci'.
											Chart dependencies, which are not bundled in the umbrella chart artifact, are not verified.
											"""
								properties: {
									matchOIDCIdentity: {
										description: """
													MatchOIDCIdentity specifies the identity matching criteria to use
													while verifying an OCI artifact which was signed using Cosign keyless
													signing. The artifact's identity is deemed to be verified if any of the
													specified matchers match against the identity.
													"""
										items: {
											description: """
														OIDCIdentityMatch specifies options for verifying the certificate identity,
														i.e. the issuer and the subject of the certificate.
														"""
											properties: {
												issuer: {
													description: """
																Issuer specifies the regex pattern to match against to verify
																the OIDC issuer in the Fulcio certificate. The pattern must be a
																valid Go regular expression.
																"""
													type: "string"
												}
												subject: {
													description: """
																Subject specifies the regex pattern to match against to verify
																the identity subject in the Fulcio certificate. The pattern must
																be a valid Go regular expression.
																"""
													type: "string"
												}
											}
											required: ["issuer", "subject"]
											type: "object"
										}
										type: "array"
									}
									provider: {
										default:     "cosign"
										description: "Provider specifies the technology used to sign the OCI Artifact."
										enum: ["cosign", "notation"]
										type: "string"
									}
									secretRef: {
										description: """
													SecretRef specifies the Kubernetes Secret containing the
													trusted public keys.
													"""
										properties: name: {
											description: "Name of the referent."
											type:        "string"
										}
										required: ["name"]
										type: "object"
									}
								}
								required: ["provider"]
								type: "object"
							}
							version: {
								default: "*"
								description: """
											Version is the chart version semver expression, ignored for charts from
											GitRepository and Bucket sources. Defaults to latest when omitted.
											"""
								type: "string"
							}
						}
						required: ["chart", "interval", "sourceRef"]
						type: "object"
					}
					status: {
						default: observedGeneration: -1
						description: "HelmChartStatus records the observed state of the HelmChart."
						properties: {
							artifact: {
								description: "Artifact represents the output of the last successful reconciliation."
								properties: {
									digest: {
										description: "Digest is the digest of the file in the form of '<algorithm>:<checksum>'."
										pattern:     "^[a-z0-9]+(?:[.+_-][a-z0-9]+)*:[a-zA-Z0-9=_-]+$"
										type:        "string"
									}
									lastUpdateTime: {
										description: """
													LastUpdateTime is the timestamp corresponding to the last update of the
													Artifact.
													"""
										format: "date-time"
										type:   "string"
									}
									metadata: {
										additionalProperties: type: "string"
										description: "Metadata holds upstream information such as OCI annotations."
										type:        "object"
									}
									path: {
										description: """
													Path is the relative file path of the Artifact. It can be used to locate
													the file in the root of the Artifact storage on the local file system of
													the controller managing the Source.
													"""
										type: "string"
									}
									revision: {
										description: """
													Revision is a human-readable identifier traceable in the origin source
													system. It can be a Git commit SHA, Git tag, a Helm chart version, etc.
													"""
										type: "string"
									}
									size: {
										description: "Size is the number of bytes in the file."
										format:      "int64"
										type:        "integer"
									}
									url: {
										description: """
													URL is the HTTP address of the Artifact as exposed by the controller
													managing the Source. It can be used to retrieve the Artifact for
													consumption, e.g. by another controller applying the Artifact contents.
													"""
										type: "string"
									}
								}
								required: ["lastUpdateTime", "path", "revision", "url"]
								type: "object"
							}
							conditions: {
								description: "Conditions holds the conditions for the HelmChart."
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
							observedChartName: {
								description: """
											ObservedChartName is the last observed chart name as specified by the
											resolved chart reference.
											"""
								type: "string"
							}
							observedGeneration: {
								description: """
											ObservedGeneration is the last observed generation of the HelmChart
											object.
											"""
								format: "int64"
								type:   "integer"
							}
							observedSourceArtifactRevision: {
								description: """
											ObservedSourceArtifactRevision is the last observed Artifact.Revision
											of the HelmChartSpec.SourceRef.
											"""
								type: "string"
							}
							observedValuesFiles: {
								description: """
											ObservedValuesFiles are the observed value files of the last successful
											reconciliation.
											It matches the chart in the last successfully reconciled artifact.
											"""
								items: type: "string"
								type: "array"
							}
							url: {
								description: """
											URL is the dynamic fetch link for the latest Artifact.
											It is provided on a "best effort" basis, and using the precise
											BucketStatus.Artifact data is recommended.
											"""
								type: "string"
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
		}]
	}
}
