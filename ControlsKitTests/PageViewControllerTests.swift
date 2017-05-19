//
//  PageViewControllerTests.swift
//  ControlsKit
//
//  Created by Stéphane Copin on 5/19/17.
//  Copyright © 2017 Stéphane Copin. All rights reserved.
//

import Quick
import Nimble
import Foundation
import ControlsKit

class TestTransitionCoordinator: NSObject, UIViewControllerTransitionCoordinator {
	class TestTransitionCoordinatorContext: NSObject, UIViewControllerTransitionCoordinatorContext {
		var containerView: UIView {
			return UIView()
		}

		var completionCurve: UIViewAnimationCurve {
			return .easeInOut
		}

		var targetTransform: CGAffineTransform {
			return .identity
		}

		var completionVelocity: CGFloat {
			return 1.0
		}

		var percentComplete: CGFloat {
			return 0.0
		}

		var transitionDuration: TimeInterval {
			return 0.0
		}

		var isCancelled: Bool {
			return false
		}

		var isInteractive: Bool {
			return false
		}

		@available(iOS 10.0, *)
		var isInterruptible: Bool {
			return false
		}

		var initiallyInteractive: Bool {
			return false
		}

		var presentationStyle: UIModalPresentationStyle {
			return .currentContext
		}

		var isAnimated: Bool {
			return false
		}

		func view(forKey key: UITransitionContextViewKey) -> UIView? {
			return nil
		}

		func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
			return nil
		}
	}

	var containerView: UIView {
		return UIView()
	}

	var completionCurve: UIViewAnimationCurve {
		return .easeInOut
	}

	var targetTransform: CGAffineTransform {
		return .identity
	}

	var completionVelocity: CGFloat {
		return 1.0
	}

	var percentComplete: CGFloat {
		return 0.0
	}

	var transitionDuration: TimeInterval {
		return 0.0
	}

	var isCancelled: Bool {
		return false
	}

	var isInteractive: Bool {
		return false
	}

	@available(iOS 10.0, *)
	var isInterruptible: Bool {
		return false
	}

	var initiallyInteractive: Bool {
		return false
	}

	var presentationStyle: UIModalPresentationStyle {
		return .currentContext
	}

	var isAnimated: Bool {
		return false
	}

	func view(forKey key: UITransitionContextViewKey) -> UIView? {
		return nil
	}

	func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
		return nil
	}

	func animateAlongsideTransition(in view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
		animation?(TestTransitionCoordinatorContext())
		completion?(TestTransitionCoordinatorContext())
		return true
	}

	func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
		animation?(TestTransitionCoordinatorContext())
		completion?(TestTransitionCoordinatorContext())
		return true
	}

	@available(iOS 10.0, *)
	func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
		handler(TestTransitionCoordinatorContext())
	}

	func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
		handler(TestTransitionCoordinatorContext())
	}
}

class TestPageViewController: PageViewController {
	var willChangeToPageCalled = false
	var didChangeToPageCalled = false
	private var overridenTraitCollection: UITraitCollection?

	override func willChange(toPage page: Int) {
		self.willChangeToPageCalled = true
	}

	override func didChange(toPage page: Int) {
		self.didChangeToPageCalled = true
	}

	func simulateTraitCollectionChange(newTraitCollection: UITraitCollection, newSize size: CGSize) {
		self.willTransition(to: newTraitCollection, with: TestTransitionCoordinator())
		self.viewWillTransition(to: size, with: TestTransitionCoordinator())
		self.overridenTraitCollection = newTraitCollection
		self.traitCollectionDidChange(newTraitCollection)
	}

	override var traitCollection: UITraitCollection {
		return self.overridenTraitCollection ?? super.traitCollection
	}
}

extension PageViewControllerTitleView {
	// For test purposes
	@NSManaged var compactTitleView: UIView
	@NSManaged var regularTitleView: UIView
}

class PageViewControllerSpec: QuickSpec {
	override func spec() {
		describe("a page view controller") {
			func tests(type: String, for viewControllerClosure: @escaping () -> TestPageViewController) {
				describe("when \(type)") {
					var navigationController: UINavigationController!
					var viewController: TestPageViewController!
					var page1ViewController: TestViewController!
					var page2ViewController: TestViewController!
					beforeEach {
						viewController = viewControllerClosure()
						page1ViewController = TestViewController()
						page1ViewController.navigationItem.title = "View 1"
						page2ViewController = TestViewController()
						page2ViewController.navigationItem.title = "View 2"
						viewController.viewControllers = [page1ViewController, page2ViewController]
						navigationController = UINavigationController(rootViewController: viewController)
						_ = viewController.view
					}
					context("when its title is displayed") {
						beforeEach {
							viewController.currentPage = 0
						}
						it("doesn't change anything") {
							expect(viewController.currentPage).to(equal(0))
						}
						it("doesn't call its overridable methods") {
							expect(viewController.willChangeToPageCalled).to(beFalse())
							expect(viewController.didChangeToPageCalled).to(beFalse())
						}
						it("doesn't change the title view position") {
							expect(viewController.titleView.currentPosition).to(equal(0.0))
						}
					}
					describe("its page changes") {
						context("changed to page 0") {
							it("doesn't change anything") {
								expect(viewController.currentPage).to(equal(0))
							}
							it("doesn't call its overridable methods") {
								expect(viewController.willChangeToPageCalled).to(beFalse())
								expect(viewController.didChangeToPageCalled).to(beFalse())
							}
							it("doesn't change the title view position") {
								expect(viewController.titleView.currentPosition).to(equal(0.0))
							}
							it("handles the title view") {
								expect(viewController.navigationItem.titleView).toNot(beNil())
							}
							context("when paged title view is not displayed") {
								beforeEach {
									viewController.displayPagedTitleView = false
									viewController.beginAppearanceTransition(true, animated: false)
									viewController.endAppearanceTransition()
								}
								it("should have the title of the currently displayed view controller") {
									expect(viewController.navigationItem.title).to(equal(page1ViewController.navigationItem.title))
								}
							}
						}
						context("changed to invalid page") {
							beforeEach {
								viewController.currentPage = -1
							}
							it("doesn't change anything") {
								expect(viewController.currentPage).to(equal(0))
							}
							it("doesn't call its overridable methods") {
								expect(viewController.willChangeToPageCalled).to(beFalse())
								expect(viewController.didChangeToPageCalled).to(beFalse())
							}
							it("doesn't change the title view position") {
								expect(viewController.titleView.currentPosition).to(equal(0.0))
							}
							it("handles the title view") {
								expect(viewController.navigationItem.titleView).toNot(beNil())
							}
							context("when paged title view is not displayed") {
								beforeEach {
									viewController.displayPagedTitleView = false
									viewController.beginAppearanceTransition(true, animated: false)
									viewController.endAppearanceTransition()
								}
								it("should have the title of the currently displayed view controller") {
									expect(viewController.navigationItem.title).to(equal(page1ViewController.navigationItem.title))
								}
							}
						}
						context("changed to page 1") {
							beforeEach {
								viewController.currentPage = 1
							}
							it("change the current page to 1") {
								expect(viewController.currentPage).to(equal(1))
							}
							it("calls its overridable methods") {
								expect(viewController.willChangeToPageCalled).to(beTrue())
								expect(viewController.didChangeToPageCalled).to(beTrue())
							}
							it("changes the title view position to page 1") {
								expect(viewController.titleView.currentPosition).to(equal(1.0))
							}
							it("title view should be handled by the PageViewController") {
								expect(viewController.navigationItem.titleView).toNot(beNil())
							}
							context("when paged title view is not displayed") {
								beforeEach {
									viewController.displayPagedTitleView = false
									viewController.beginAppearanceTransition(true, animated: false)
									viewController.endAppearanceTransition()
								}
								it("should have the title of the currently displayed view controller") {
									expect(viewController.navigationItem.title).to(equal(page2ViewController.navigationItem.title))
								}
							}
						}
						if viewControllerClosure().transitionStyle == .scroll {
							context("when scrolled half-way") {
								beforeEach {
									viewController.currentPage = 1 // load the next page
									viewController.currentPage = 0
									if viewController.navigationOrientation == .horizontal {
										viewController.internalScrollView.contentOffset.x = viewController.internalScrollView.contentSize.width / 2.0
									} else {
										viewController.internalScrollView.contentOffset.y = viewController.internalScrollView.contentSize.height / 2.0
									}
								}
								it("should update its title view position accordingly") {
									RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
									// There can be a rounding error due to iOS using integral CGRect internally
									expect(viewController.titleView.currentPosition).to(beCloseTo(0.5, within: 0.01))
								}
							}
						}
						context("when the delegate is set") {
							it("should stay as the predefined delegate") {
								class TestDelegate: NSObject, UIPageViewControllerDelegate {

								}
								let testDelegate = TestDelegate()
								let originalDelegate = viewController.delegate
								viewController.delegate = testDelegate
								expect(viewController.delegate) === originalDelegate
							}
						}
						context("when the data source is set") {
							it("should stay as the predefined data source") {
								class TestDataSource: NSObject, UIPageViewControllerDataSource {
									func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
										return nil
									}

									func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
										return nil
									}
								}
								let testDataSource = TestDataSource()
								let originalDataSource = viewController.dataSource
								viewController.dataSource = testDataSource
								expect(viewController.dataSource) === originalDataSource
							}
						}
						context("when its size class changes") {
							beforeEach {
								viewController.beginAppearanceTransition(true, animated: false)
								viewController.endAppearanceTransition()
								class RegularHorizontalTraitCollection: UITraitCollection {
									override var horizontalSizeClass: UIUserInterfaceSizeClass {
										return .regular
									}

									override var verticalSizeClass: UIUserInterfaceSizeClass {
										return .compact
									}
								}
								viewController.simulateTraitCollectionChange(newTraitCollection: RegularHorizontalTraitCollection(), newSize: viewController.view.bounds.size)
							}

							it("updates the title view size class accordingly") {
								expect(viewController.titleView.compactTitleView.alpha).to(equal(0.0))
								expect(viewController.titleView.regularTitleView.alpha).to(equal(1.0))
							}

							context("when its size class is reverted") {
								it("updates the title view size class accordingly") {
									class CompactTraitCollection: UITraitCollection {
										override var horizontalSizeClass: UIUserInterfaceSizeClass {
											return .compact
										}

										override var verticalSizeClass: UIUserInterfaceSizeClass {
											return .compact
										}
									}

									viewController.simulateTraitCollectionChange(newTraitCollection: CompactTraitCollection(), newSize: viewController.view.bounds.size)
									expect(viewController.titleView.compactTitleView.alpha).to(equal(1.0))
									expect(viewController.titleView.regularTitleView.alpha).to(equal(0.0))
								}
							}
						}
					}
				}
			}

			tests(type: "loaded with default init", for: { TestPageViewController() })
			tests(type: "loaded with horizontal scroll", for: { TestPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil) })
			tests(type: "loaded with vertical scroll", for: { TestPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil) })
			tests(type: "loaded with horizontal curl animation", for: { TestPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil) })
			tests(type: "loaded with vertical animation", for: { TestPageViewController(transitionStyle: .pageCurl, navigationOrientation: .vertical, options: nil) })
		}
	}
}
