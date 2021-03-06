//
//  PSPDFModel.h
//  PSPDFKit
//
//  Copyright (c) 2012-2013 Peter Steinberger. All rights reserved.
//  Based on GitHub's Mantle project, MIT licensed.
//

#import <Foundation/Foundation.h>

/// An external representation format specifying encoding to or decoding from a keyed archive using NSKeyedArchiver and NSKeyedUnarchiver.
extern NSString *const PSPDFModelKeyedArchiveFormat;

/// An external representation format specifying encoding to or decoding from a JSON dictionary.
extern NSString *const PSPDFModelJSONFormat;

/// An abstract base class for model objects with sensible defaults.
//
/// PSPDFModel has a concept of an "external representation," which is like
/// a serialized version of the model object. By default, the only external
/// representation formats defined are PSPDFModelKeyedArchiveFormat and
/// PSPDFModelJSONFormat, but applications can use their own format names and
/// implement their own serialization behaviors as desired.
@interface PSPDFModel : NSObject <NSCoding, NSCopying>

/// @name Initialization

/// Return any property keys that should be serialized.
///
/// Override this in your subclass and list any properties that should be serialized.
/// If `externalRepresentationFormat` is nil, return all available properties.
+ (NSOrderedSet *)propertyKeysInFormat:(NSString *)externalRepresentationFormat;

/// Returns a new instance of the receiver initialized using
/// -initWithDictionary:.
+ (instancetype)modelWithDictionary:(NSDictionary *)dictionaryValue;

/// Returns a new instance of the receiver initialized using
/// -initWithExternalRepresentation:inFormat:.
+ (instancetype)modelWithExternalRepresentation:(id)externalRepresentation inFormat:(NSString *)externalRepresentationFormat;

/// Initializes the receiver with default values.
//
/// This is the designated initializer for this class.
- (id)init;

/// Initializes the receiver using key-value coding, setting the keys and values
/// in the given dictionary. If `dictionaryValue` is nil, this method is equivalent
/// to -init.
///
/// Any NSNull values will be converted to nil before being used. KVC validation
/// methods will be automatically invoked for all of the properties given.
///
/// Returns an initialized model object, or nil if validation failed.
- (id)initWithDictionary:(NSDictionary *)dictionaryValue;

/// Invokes -initWithDictionary: after mapping the given external
/// representation using +keyPathsByPropertyKeyForExternalRepresentationFormat:
/// and +transformerForPropertyKey:externalRepresentationFormat:.
///
/// Any NSNull values will be converted to nil before being used. KVC validation
/// methods will be automatically invoked for any transformed values.
///
/// Returns an initialized model object, or nil if validation failed or
/// `externalRepresentation` was nil.
- (id)initWithExternalRepresentation:(id)externalRepresentation inFormat:(NSString *)externalRepresentationFormat;

/// Decodes an external representation in PSPDFModelKeyedArchiveFormat from the
/// given coder, migrates it (if necessary) using
/// -migrateExternalRepresentation:inFormat:fromVersion:, and then initializes
/// the receiver with -initWithExternalRepresentation:inFormat:.
- (id)initWithCoder:(NSCoder *)coder;

/// If no external representation is found, try initializing the models using the legacy code.
///
/// Override for legacy decoding support.
- (id)initWithLegacyCoder:(NSCoder *)decoder;

/// Hook to update variables after model has been loaded from dictionary/external represenation/copied.
///
/// Default implementation is empty. Always call super.
- (void)didLoadModelInstance;

/// @name Copy/Serialization

/// Returns a copy of the receiver, initialized using -initWithDictionary: with
/// the receiver's dictionaryValue.
- (id)copyWithZone:(NSZone *)zone;

/// Serializes the receiver with the given coder, according to the behaviors
/// specified by +encodingBehaviorForPropertyKey:externalRepresentationFormat:.
///
/// From the receiver's dictionaryValue, this method retrieves any properties
/// that should be encoded, transforms them using
// +keyPathsByPropertyKeyForExternalRepresentationFormat: and any reversible
// transformers returned by
// +transformerForPropertyKey:externalRepresentationFormat:, then encodes them
// according to the specified PSPDFModelEncodingBehavior.
- (void)encodeWithCoder:(NSCoder *)coder;

/// @name External representation

/// Specifies how to map @property keys to different key paths in the given
/// external representation format. Subclasses overriding this method should
/// combine their values with those of super.
///
/// Any keys not present in the dictionary are assumed to be the same for
/// @property declarations and the external representation.
///
/// Returns an empty dictionary.
+ (NSDictionary *)keyPathsByPropertyKeyForExternalRepresentationFormat:(NSString *)externalRepresentationFormat;

/// Specifies how to transform an external representation value to the given
/// @property key. If reversible, the transformer will also be used to convert
/// the property value back to its external representation.
///
/// By default, this method looks for
/// a `+<key>TransformerForExternalRepresentationFormat:` method on the receiver,
/// and invokes it if found.
///
/// Returns a value transformer, or nil if no transformation should be performed.
+ (NSValueTransformer *)transformerForPropertyKey:(NSString *)key externalRepresentationFormat:(NSString *)externalRepresentationFormat;

/// A dictionary representing the properties of the receiver.
///
/// The default implementation combines the values corresponding to all
/// +propertyKeys into a dictionary, with any nil values represented by NSNull.
///
/// This property must never be nil.
@property (nonatomic, copy, readonly) NSDictionary *dictionaryValue;

/// Transforms the receiver's dictionaryValue into the given external
/// representation format, suitable for serialization.
///
/// The keys in the dictionaryValue are mapped using
/// +keyPathsByPropertyKeyForExternalRepresentationFormat:, and the values are
/// mapped using any reversible transformers returned by
/// +transformerForPropertyKey:externalRepresentationFormat:.
///
/// Any keys for which
/// -encodingBehaviorForPropertyKey:externalRepresentationFormat: returns
/// PSPDFModelEncodingBehaviorNone will be omitted from the returned dictionary.
/// All other keys will be included by default.
///
/// For any external representation key paths where values along the path are
/// nil (but the final value is not), dictionaries are automatically added so
/// that the value can be correctly set at the complete key path.
- (id)externalRepresentationInFormat:(NSString *)externalRepresentationFormat;

/// @name Migration

/// The version of this PSPDFModel subclass.
///
/// Returns 0.
+ (NSUInteger)modelVersion;

/// Migrates an external representation in a specified format from an older model
/// version.
///
/// This method is only invoked by PSPDFModel from -initWithCoder:, and only if an
/// older version of the receiver is unarchived.
///
/// Returns `externalRepresentation` without any changes. Subclasses may return
/// nil if unarchiving should fail.
+ (NSDictionary *)migrateExternalRepresentation:(id)externalRepresentation inFormat:(NSString *)externalRepresentationFormat fromVersion:(NSUInteger)fromVersion;

/// Merges the value of the given key on the receiver with the value of the same
/// key from the given model object, giving precedence to the other model object.
///
/// By default, this method looks for a `-merge<Key>FromModel:` method on the
/// receiver, and invokes it if found. If not found, and `model` is not nil, the
/// value for the given key is taken from `model`.
- (void)mergeValueForKey:(NSString *)key fromModel:(PSPDFModel *)model;

/// Merges the values of the given model object into the receiver, using
/// -mergeValueForKey:fromModel: for each key in +propertyKeys.
///
/// `model` must be an instance of the receiver's class or a subclass thereof.
- (void)mergeValuesForKeysFromModel:(PSPDFModel *)model;

/// Returns a hash of the receiver's dictionaryValue.
- (NSUInteger)hash;

/// Returns whether `model` is of the exact same class as the receiver, and
/// whether its dictionaryValue compares equal to the receiver's.
- (BOOL)isEqual:(PSPDFModel *)model;

@end
