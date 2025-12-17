import { Column, CreateDateColumn, Entity, ManyToOne, OneToMany, PrimaryColumn, PrimaryGeneratedColumn, UpdateDateColumn } from "typeorm";
import { User } from "./user.entity";
import { SavingPlanCheckout } from "./saving_plan_checkout_entity";

@Entity()
export class SavingPlan {
    @PrimaryGeneratedColumn() //it is used to generate primary id, when new data inserted.
    id: number;

    @Column({length:100,}) // It is used to mark a specific class property as a table column
    name: string;

    @Column({type:'enum', enum:['monthly', 'weekly', 'daily'], default:'monthly'})
    type_reminder: string

    @Column({length:10, nullable:true})
    date_reminder?: string

    @Column({type:'date'})
    target_date: string;
    

    @Column({type:'decimal', precision:20, scale:2})
    target_money: number;

    @Column({type:'boolean', default:true})
    notification: boolean;
    
    @ManyToOne(() => User, (user)=> user.savingPlans, {onDelete:'NO ACTION'})
    user: User;

    @OneToMany(()=> SavingPlanCheckout, (data)=>data.savingPlan, {onDelete:'CASCADE', onUpdate:'CASCADE'})
    checkout: SavingPlanCheckout[]
    
    @CreateDateColumn()
    createdon: Date;
    
    @UpdateDateColumn()
    updatedon: Date;

    
}