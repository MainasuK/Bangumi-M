//
//  Parser.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2016-7-25.
//  Copyright © 2016年 Cirno MainasuK. All rights reserved.
//

import XCTest

@testable import Bangumi_M
import Kanna

// swiftlint:disable line_length
class Parser: XCTestCase {

    let book = "<div class=\"subject_section\"><h2 class=\"subtitle\">单行本</h2><ul class=\"browserCoverSmall clearit\"><li><a href=\"/subject/12475\" title=\"さくら荘のペットな彼女 〈1〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/eb/ea/12475_jp.jpg')\"></span></a></li><li><a href=\"/subject/12476\" title=\"さくら荘のペットな彼女 〈2〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/4f/6e/12476_jp.jpg')\"></span></a></li><li><a href=\"/subject/14599\" title=\"さくら荘のペットな彼女 〈3〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/39/58/14599_68Gkv.jpg')\"></span></a></li><li><a href=\"/subject/18220\" title=\"さくら荘のペットな彼女 〈4〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/ab/fd/18220_VE8s8.jpg')\"></span></a></li><li><a href=\"/subject/26692\" title=\"さくら荘のペットな彼女 〈5〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/2d/56/26692_jp.jpg')\"></span></a></li><li><a href=\"/subject/26693\" title=\"さくら荘のペットな彼女 〈5.5〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/14/d9/26693_jp.jpg')\"></span></a></li><li><a href=\"/subject/37877\" title=\"さくら荘のペットな彼女 〈6〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/e7/3f/37877_jp.jpg')\"></span></a></li><li><a href=\"/subject/37878\" title=\"さくら荘のペットな彼女 〈7〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/5a/dd/37878_jp.jpg')\"></span></a></li><li><a href=\"/subject/46745\" title=\"さくら荘のペットな彼女 〈7.5〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/fc/77/46745_jp.jpg')\"></span></a></li><li><a href=\"/subject/50836\" title=\"さくら荘のペットな彼女 〈8〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/20/e3/50836_jp.jpg')\"></span></a></li><li><a href=\"/subject/67038\" title=\"さくら荘のペットな彼女 〈9〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/fa/a2/67038_jp.jpg')\"></span></a></li><li><a href=\"/subject/78657\" title=\"さくら荘のペットな彼女 〈10〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/26/10/78657_xJpxP.jpg')\"></span></a></li><li><a href=\"/subject/100135\" title=\"さくら荘のペットな彼女 〈10.5〉\" class=\"avatar thumbTipSmall\"><span class=\"avatarNeue avatarSize48\" style=\"background-image:url('//lain.bgm.tv/pic/cover/g/7e/0f/100135_8xGz0.jpg')\"></span></a></li></ul></div>"

    let topicTable = "<table class=\"topic_list\" border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tbody><tr><td class=\"odd\"><a href=\"/subject/topic/5663\" title=\"三女算是neta高达00么？\" class=\"l\">三女算是neta高达00么？</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/209942\">あんたじゃもえねいな!</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">16 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-30</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/6739\" title=\"恭喜我箱拿下东京动画赏\" class=\"l\">恭喜我箱拿下东京动画赏</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/269801\">百升飞上天</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">5 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2016-3-21</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/6639\" title=\"[转自s1][板野一郎]《白箱》BD第2卷评论音轨，板野一郎×堀川宪司×永谷敬之——感谢jacket翻译\" class=\"l\">[转自s1][板野一郎]《白箱》BD第2卷评论音轨，板野一郎×堀川宪司×永谷敬之——感谢jacket翻译</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/myhead\">myhead</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">5 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2016-2-13</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5652\" title=\"白箱评分及rank讨论//15.9.8 排名到第9了\" class=\"l\">白箱评分及rank讨论//15.9.8 排名到第9了</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/barcelona\">巴达兽[s]Barcelona[/s]</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">330 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-28</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/6584\" title=\"好想p 2333\" class=\"l\">好想p 2333</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/demonpaean\">DemonPaean</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2016-1-22</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/6285\" title=\"[转自s1](长篇翻译)《白箱》BD第8卷，双水岛评论音轨，水岛努×水岛精二——感谢jacket翻译\" class=\"l\">[转自s1](长篇翻译)《白箱》BD第8卷，双水岛评论音轨，水岛努×水岛精二——感谢jacket翻译</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/myhead\">myhead</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">21 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-10-7</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/6535\" title=\"好好也想穿哥特萝莉裙~\" class=\"l\">好好也想穿哥特萝莉裙~</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/haohao69\">好好</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">57 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2016-1-4</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5731\" title=\"大胆预测白箱今年会拿文化厅赏\" class=\"l\">大胆预测白箱今年会拿文化厅赏</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/239869\">剿灭百匪</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">15 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-4-15</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5172\" title=\"有人真的给喵森发了邮件还被回复了\" class=\"l\">有人真的给喵森发了邮件还被回复了</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/skyxxzc\">SkyXxzc</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">31 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-24</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/6417\" title=\"SHIROBAKO获得第19回文化厅媒体艺术祭动画部门审查委员会推荐\" class=\"l\">SHIROBAKO获得第19回文化厅媒体艺术祭动画部门审查委员会推荐</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/239869\">剿灭百匪</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">12 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-11-27</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/6405\" title=\"有点在意为什么白箱会有百合的标签。。。\" class=\"l\">有点在意为什么白箱会有百合的标签。。。</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/benshu\">本树</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">16 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-11-21</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/6376\" title=\"最终话ED集体照排位问题\" class=\"l\">最终话ED集体照排位问题</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/250995\">萝丝控</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">8 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-11-8</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5763\" title=\"一部被吹得有点过头的作品\" class=\"l\">一部被吹得有点过头的作品</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/dustinsocks\">Dustinsocks</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">80 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-4-24</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/6006\" title=\"【悲报】PA社长：白箱没有第二季。\" class=\"l\">【悲报】PA社长：白箱没有第二季。</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/251402\">Dertah</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">26 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-7-10</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/6028\" title=\"[转自s1]《白箱》制作进行座谈会：相马×山本×桥本×吉田×小竹——感谢jacket翻译\" class=\"l\">[转自s1]《白箱》制作进行座谈会：相马×山本×桥本×吉田×小竹——感谢jacket翻译</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/myhead\">myhead</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">4 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-7-17</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5989\" title=\"[转自s1] 《白箱》制作人相马绍二采访水岛努监督，地点居酒屋柗亭——感谢jacket翻译\" class=\"l\">[转自s1] 《白箱》制作人相马绍二采访水岛努监督，地点居酒屋柗亭——感谢jacket翻译</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/myhead\">myhead</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">9 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-7-6</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5146\" title=\"[转] 声优&amp;STAFF的二次元&amp;三次元的考据与对比\" class=\"l\">[转] 声优&amp;STAFF的二次元&amp;三次元的考据与对比</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/spiritistz\">ひかる</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">10 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-18</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5253\" title=\"日本动画从业者年薪\" class=\"l\">日本动画从业者年薪</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/time_poor\">时光可怜</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">71 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-11-20</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5640\" title=\"偶然间发现的几个抛弃并打一分的用户\" class=\"l\">偶然间发现的几个抛弃并打一分的用户</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/nenu_xlp\">夏蓝谱</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">43 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-20</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5684\" title=\"从头再看一遍挺有意思\" class=\"l\">从头再看一遍挺有意思</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/lifeonly\">山泉水</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">3 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-4-3</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5716\" title=\"静香配音时的宫森哭戏，史上最佳！\" class=\"l\">静香配音时的宫森哭戏，史上最佳！</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/193180\">能改就随便了</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">1 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-4-11</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5683\" title=\"[转自s1]AniKo对白箱制片人川濑浩平的访谈，感谢jacket翻译\" class=\"l\">[转自s1]AniKo对白箱制片人川濑浩平的访谈，感谢jacket翻译</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/myhead\">myhead</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">5 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-4-2</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5649\" title=\"年鉴的排名是怎么算的？眼见白箱跑到第一\" class=\"l\">年鉴的排名是怎么算的？眼见白箱跑到第一</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/chrysalis\">茧</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">15 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-27</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5175\" title=\"如果山本宽来拍这个片会怎么样？\" class=\"l\">如果山本宽来拍这个片会怎么样？</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/dybnu\">夏小芽</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">8 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-25</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5605\" title=\"PA这算自黑么bgm38\" class=\"l\">PA这算自黑么bgm38</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/dangge\">当歌</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">23 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-5</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5606\" title=\"转个全话数NETA/考据链结 日语注意\" class=\"l\">转个全话数NETA/考据链结 日语注意</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/26866\">月火・セイブザワールド</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-3-7</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5517\" title=\"OST1下载\" class=\"l\">OST1下载</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/minorin\">有希的消失</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">1 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2015-2-6</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5258\" title=\"白箱OPED已偷跑（附试听）\" class=\"l\">白箱OPED已偷跑（附试听）</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/treehole\">树洞酱</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-11-22</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5137\" title=\"【第二集】我确实被他们对动画的热情感染了\" class=\"l\">【第二集】我确实被他们对动画的热情感染了</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/barcelona\">巴达兽[s]Barcelona[/s]</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">10 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-17</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5085\" title=\"大家是放弃PA了么\" class=\"l\">大家是放弃PA了么</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/chrysalis\">茧</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">142 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-2</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5178\" title=\"劇中劇アニメーション「えくそだすっ！」将有俩话同捆发售\" class=\"l\">劇中劇アニメーション「えくそだすっ！」将有俩话同捆发售</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/gllovelove\">墨雨和风</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">4 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-26</small></td></tr><tr><td class=\"even\"><a href=\"/subject/topic/5121\" title=\"PA 向竞争对手 Production I.G 宣战吗？\" class=\"l\">PA 向竞争对手 Production I.G 宣战吗？</a></td><td class=\"even\" width=\"15%\"><a href=\"/user/vxxxv\">灰邑詠子</a></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">6 replies</small></td><td class=\"even\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-13</small></td></tr><tr><td class=\"odd\"><a href=\"/subject/topic/5119\" title=\"【人物关系整理】\" class=\"l\">【人物关系整理】</a></td><td class=\"odd\" width=\"15%\"><a href=\"/user/taxet\">名媛小百合</a></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">3 replies</small></td><td class=\"odd\" width=\"15%\" align=\"right\"><small class=\"grey\">2014-10-12</small></td></tr></tbody></table>"

    // swiftlint:disable function_body_length cyclomatic_complexity
    func testTopic() {
        let doc = Kanna.HTML(html: topicTable, encoding: String.Encoding.utf8)
        let bodyNode = doc?.body
        
        if let table = bodyNode?.at_xpath("//table[@class='topic_list']") {
            
            for row in table.css("tr") {   // row
                var urlPath = "https://bgm.tv/"
                var title = ""
                var uid = 0
                var userName = ""
                var replies = 0
                var date = ""

                for (i, node) in row.css("td").enumerated() {   // col
                    switch i {
                    case 0:
                        if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                        let hrefNode = nodeset.first,
                        let href = hrefNode["href"],
                        let text = node.text {
                            urlPath += href
                            title = text
                            
                            XCTAssertNotEqual(urlPath, "https://bgm.tv/")
                            XCTAssertNotEqual(title, "")
                        }
                        
                    case 1:
                        if case let XPathObject.NodeSet(nodeset) = node.css("a[href]"),
                        let hrefNode = nodeset.first,
                        let href = hrefNode["href"],
                        let lastSplitOfHref = href.components(separatedBy: "/").last,
                        let id = Int(lastSplitOfHref),
                        let text = hrefNode.text {
                            uid = id
                            userName = text
                            
                            XCTAssertNotEqual(uid, 0)
                            XCTAssertNotEqual(userName, "")
                            
                            print(text)
                        }
                        
                    case 2:
                        if let text = node.text,
                        let repliesStr = text.components(separatedBy: " ").first,
                        let repliesInt = Int(repliesStr) {
                            replies = repliesInt
                            
                            XCTAssertNotEqual(replies, -1)
                        }
                        
                    case 3:
                        if let text = node.text {
                            date = text
                            
                            XCTAssertNotEqual(date, "")
                        }
                        
                    default:
                        break
                    }
                    
                }   // end col
                
//                for col in row.css("td") {
//                    
//                    print(col.toHTML)
//                }
                
                //print(row.toHTML)
            }   // end row
            
            //print(table.toHTML)
        }   // end if let table …
    }
    
    func testBook() {
        
    }

}
