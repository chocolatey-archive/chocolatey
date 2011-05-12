using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Xml;
using FubuCore.Reflection;
using NUnit.Framework;
using NUnit.Framework.Constraints;
using Rhino.Mocks;
using Rhino.Mocks.Constraints;
using Rhino.Mocks.Interfaces;
using Is = NUnit.Framework.Is;

namespace Chocolatey.Tests
{
    public static class Exception<T> where T : Exception
    {
        public static T ShouldBeThrownBy(Action action)
        {
            T exception = null;

            try
            {
                action();
            }
            catch (Exception e)
            {
                exception = e.ShouldBeOfType<T>();
            }

            if (exception == null) Assert.Fail("An exception was expected, but not thrown by the given action.");

            return exception;
        }
    }

    public delegate void MethodThatThrows();

    public static class SpecificationExtensions
    {
        public static void ShouldHave<T>(this IEnumerable<T> values, Func<T, bool> func)
        {
            values.FirstOrDefault(func).ShouldNotBeNull();
        }

        public static void ShouldNotHave<T>(this IEnumerable<T> values, Func<T, bool> func)
        {
            values.FirstOrDefault(func).ShouldBeNull();
        }

        public static void ShouldBeFalse(this bool condition)
        {
            Assert.IsFalse(condition);
        }

        public static void ShouldBeTrue(this bool condition)
        {
            Assert.IsTrue(condition);
        }

        public static void ShouldBeTrueBecause(this bool condition, string reason, params object[] args)
        {
            Assert.IsTrue(condition, reason, args);
        }

        public static object ShouldEqual(this object actual, object expected)
        {
            Assert.AreEqual(expected, actual);
            return expected;
        }

        public static object ShouldEqual(this string actual, object expected)
        {
            Assert.AreEqual((expected != null) ? expected.ToString() : null, actual);
            return expected;
        }

        public static void ShouldMatch(this string actual, string pattern)
        {
            Assert.That(actual, Is.StringMatching(pattern));
        }

        public static XmlElement AttributeShouldEqual(this XmlElement element, string attributeName, object expected)
        {
            Assert.IsNotNull(element, "The Element is null");

            string actual = element.GetAttribute(attributeName);
            Assert.AreEqual(expected, actual);
            return element;
        }

        public static XmlElement AttributeShouldEqual(this XmlNode node, string attributeName, object expected)
        {
            var element = node as XmlElement;

            Assert.IsNotNull(element, "The Element is null");

            string actual = element.GetAttribute(attributeName);
            Assert.AreEqual(expected, actual);
            return element;
        }

        public static XmlElement ShouldHaveChild(this XmlElement element, string xpath)
        {
            var child = element.SelectSingleNode(xpath) as XmlElement;
            Assert.IsNotNull(child, "Should have a child element matching " + xpath);

            return child;
        }

        public static XmlElement DoesNotHaveAttribute(this XmlElement element, string attributeName)
        {
            Assert.IsNotNull(element, "The Element is null");
            Assert.IsFalse(element.HasAttribute(attributeName),
                           "Element should not have an attribute named " + attributeName);

            return element;
        }

        public static object ShouldNotEqual(this object actual, object expected)
        {
            Assert.AreNotEqual(expected, actual);
            return expected;
        }

        public static void ShouldBeNull(this object anObject)
        {
            Assert.IsNull(anObject);
        }

        public static T ShouldNotBeNull<T>(this T anObject)
        {
            Assert.IsNotNull(anObject);
            return anObject;
        }

        public static void ShouldNotBeNull(this object anObject, string message)
        {
            Assert.IsNotNull(anObject, message);
        }

        public static object ShouldBeTheSameAs(this object actual, object expected)
        {
            Assert.AreSame(expected, actual);
            return expected;
        }

        public static object ShouldNotBeTheSameAs(this object actual, object expected)
        {
            Assert.AreNotSame(expected, actual);
            return expected;
        }

        public static T ShouldBeOfType<T>(this object actual)
        {
            actual.ShouldNotBeNull();
            actual.ShouldBeOfType(typeof (T));
            return (T) actual;
        }

        public static T As<T>(this object actual)
        {
            actual.ShouldNotBeNull();
            actual.ShouldBeOfType(typeof (T));
            return (T) actual;
        }

        public static object ShouldBeOfType(this object actual, Type expected)
        {
            Assert.IsInstanceOf(expected, actual);
            return actual;
        }

        public static void ShouldNotBeOfType(this object actual, Type expected)
        {
            Assert.IsNotInstanceOf(expected, actual);
        }

        public static void ShouldNotBeOfType<T>(this object actual)
        {
            Assert.IsNotInstanceOf(typeof(T), actual);
        }

        public static void ShouldContain(this IList actual, object expected)
        {
            Assert.Contains(expected, actual);
        }

        public static void ShouldContain<T>(this IEnumerable<T> actual, T expected)
        {
            if (actual.Count(t => t.Equals(expected)) == 0)
            {
                Assert.Fail("The item '{0}' was not found in the sequence.", expected);
            }
        }

        public static void ShouldNotBeEmpty<T>(this IEnumerable<T> actual)
        {
            Assert.Greater(actual.Count(), 0, "The list should have at least one element");
        }

        public static void ShouldNotContain<T>(this IEnumerable<T> actual, T expected)
        {
            if (actual.Count(t => t.Equals(expected)) > 0)
            {
                Assert.Fail("The item was found in the sequence it should not be in.");
            }
        }

        public static void ShouldHaveTheSameElementsAs(this IList actual, IList expected)
        {
            try
            {
                actual.ShouldNotBeNull();
                expected.ShouldNotBeNull();

                actual.Count.ShouldEqual(expected.Count);

                for (int i = 0; i < actual.Count; i++)
                {
                    actual[i].ShouldEqual(expected[i]);
                }
            }
            catch (Exception)
            {
                Debug.WriteLine("Actual values were:");
                actual.Each(x => Debug.WriteLine(x));
                throw;
            }
        }

        public static void ShouldHaveTheSameElementsAs<T>(this IEnumerable<T> actual, params T[] expected)
        {
            ShouldHaveTheSameElementsAs(actual, (IEnumerable<T>) expected);
        }

        public static void ShouldHaveTheSameElementsAs<T>(this IEnumerable<T> actual, IEnumerable<T> expected)
        {
            IList actualList = (actual is IList) ? (IList) actual : actual.ToList();
            IList expectedList = (expected is IList) ? (IList) expected : expected.ToList();

            ShouldHaveTheSameElementsAs(actualList, expectedList);
        }

        public static void ShouldHaveTheSameElementKeysAs<ELEMENT, KEY>(this IEnumerable<ELEMENT> actual,
                                                                        IEnumerable expected,
                                                                        Func<ELEMENT, KEY> keySelector)
        {
            actual.ShouldNotBeNull();
            expected.ShouldNotBeNull();

            ELEMENT[] actualArray = actual.ToArray();
            object[] expectedArray = expected.Cast<object>().ToArray();

            actualArray.Length.ShouldEqual(expectedArray.Length);

            for (int i = 0; i < actual.Count(); i++)
            {
                keySelector(actualArray[i]).ShouldEqual(expectedArray[i]);
            }
        }

        public static IComparable ShouldBeGreaterThan(this IComparable arg1, IComparable arg2)
        {
            Assert.Greater(arg1, arg2);
            return arg2;
        }

        public static IComparable ShouldBeLessThan(this IComparable arg1, IComparable arg2)
        {
            Assert.Less(arg1, arg2);
            return arg2;
        }

        public static void ShouldBeEmpty(this ICollection collection)
        {
            Assert.IsEmpty(collection);
        }

        public static void ShouldBeEmpty(this string aString)
        {
            Assert.IsEmpty(aString);
        }

        public static void ShouldNotBeEmpty(this ICollection collection)
        {
            Assert.IsNotEmpty(collection);
        }

        public static void ShouldNotBeEmpty(this string aString)
        {
            Assert.IsNotEmpty(aString);
        }

        public static void ShouldContain(this string actual, string expected)
        {
            StringAssert.Contains(expected, actual);
        }

        public static void ShouldContainAllOf(this string actual, params string[] expectedItems)
        {
            expectedItems.Each(expected => actual.ShouldContain(expected));
        }

        public static void ShouldContain<T>(this IEnumerable<T> actual, Func<T, bool> expected)
        {
            actual.Count().ShouldBeGreaterThan(0);
            T result = actual.FirstOrDefault(expected);
            Assert.That(result, Is.Not.EqualTo(default(T)), "Expected item was not found in the actual sequence");
        }

        public static void ShouldNotContain(this string actual, string expected)
        {
            Assert.That(actual, new NotConstraint(new SubstringConstraint(expected)));
        }

        public static string ShouldBeEqualIgnoringCase(this string actual, string expected)
        {
            StringAssert.AreEqualIgnoringCase(expected, actual);
            return expected;
        }

        public static void ShouldEndWith(this string actual, string expected)
        {
            StringAssert.EndsWith(expected, actual);
        }

        public static void ShouldStartWith(this string actual, string expected)
        {
            StringAssert.StartsWith(expected, actual);
        }

        public static void ShouldContainErrorMessage(this Exception exception, string expected)
        {
            StringAssert.Contains(expected, exception.Message);
        }

        public static Exception ShouldBeThrownBy(this Type exceptionType, MethodThatThrows method)
        {
            Exception exception = null;

            try
            {
                method();
            }
            catch (Exception e)
            {
                Assert.AreEqual(exceptionType, e.GetType());
                exception = e;
            }

            if (exception == null)
            {
                Assert.Fail(String.Format("Expected {0} to be thrown.", exceptionType.FullName));
            }

            return exception;
        }


        public static void ShouldEqualSqlDate(this DateTime actual, DateTime expected)
        {
            TimeSpan timeSpan = actual - expected;
            Assert.Less(Math.Abs(timeSpan.TotalMilliseconds), 3);
        }

        public static void ShouldBe<T>(this Expression<Func<T, object>> actual, Expression<Func<T, object>> expected)
        {
            string expectedMethod = ReflectionHelper.GetMethod(expected).Name;
            string actualMethod = ReflectionHelper.GetMethod(actual).Name;
            actualMethod.ShouldEqual(expectedMethod);
        }

        public static IEnumerable<T> ShouldHaveCount<T>(this IEnumerable<T> actual, int expected)
        {
            actual.Count().ShouldEqual(expected);
            return actual;
        }

        public static void Matches(this List<string> list, params string[] values)
        {
            AssertListMatches(list, values);
        }

        public static void AssertListMatches(IList actualList, IList expectedList)
        {
            var actual = new ArrayList(actualList);
            var expected = new ArrayList(expectedList);

            foreach (object item in actual.ToArray())
            {
                actual.Remove(item);
                expected.Remove(item);
            }

            if (actual.Count == 0 && expected.Count == 0) return;

            string message = "";
            actual.Each(o => message += string.Format("Extra:  {0}\n", o));
            expected.Each(o => message += string.Format("Missing:  {0}\n", o));

            Assert.Fail(message);
        }


        public static CapturingConstraint CaptureArgumentsFor<MOCK>(this MOCK mock,
                                                                    Expression<Action<MOCK>> methodExpression)
            where MOCK : class
        {
            return SetupConstraint(
                ReflectionHelper.GetMethod(methodExpression),
                mock.Expect(methodExpression.Compile()),
                null);
        }

        public static CapturingConstraint CaptureArgumentsFor<MOCK>(this MOCK mock,
                                                                    Expression<Action<MOCK>> methodExpression,
                                                                    Action
                                                                        <IMethodOptions<RhinoMocksExtensions.VoidType>>
                                                                        optionsAction) where MOCK : class
        {
            return SetupConstraint(
                ReflectionHelper.GetMethod(methodExpression),
                mock.Expect(methodExpression.Compile()),
                optionsAction);
        }

        public static CapturingConstraint CaptureArgumentsFor<MOCK, RESULT>(
            this MOCK mock,
            Expression<Func<MOCK, RESULT>> methodExpression,
            Action<IMethodOptions<RESULT>> optionsAction)
            where MOCK : class
        {
            return SetupConstraint(
                ReflectionHelper.GetMethod(methodExpression),
                mock.Expect(new Function<MOCK, RESULT>(methodExpression.Compile())),
                optionsAction);
        }

        private static CapturingConstraint SetupConstraint<T>(MethodInfo method, IMethodOptions<T> options,
                                                              Action<IMethodOptions<T>> optionsAction)
        {
            var constraint = new CapturingConstraint();
            var constraints = new List<AbstractConstraint>();

            foreach (ParameterInfo arg in method.GetParameters())
            {
                constraints.Add(constraint);
            }

            options = options.Constraints(constraints.ToArray()).Repeat.Any();

            if (optionsAction != null)
            {
                optionsAction(options);
            }

            return constraint;
        }

        #region Nested type: CapturingConstraint

        public class CapturingConstraint : AbstractConstraint
        {
            private readonly ArrayList argList = new ArrayList();

            public override string Message { get { return ""; } }

            public override bool Eval(object obj)
            {
                argList.Add(obj);
                return true;
            }

            public T First<T>()
            {
                return ArgumentAt<T>(0);
            }

            public T ArgumentAt<T>(int pos)
            {
                return (T) argList[pos];
            }

            public T Second<T>()
            {
                return ArgumentAt<T>(1);
            }
        }

        #endregion
    }
}